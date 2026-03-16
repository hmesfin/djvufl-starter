import logging

from drf_spectacular.utils import extend_schema, inline_serializer
from rest_framework import serializers, status
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.payments.models import Payment
from apps.payments.services import create_connect_account_link
from apps.payments.services import process_webhook

logger = logging.getLogger(__name__)


class StripeConnectOnboardView(APIView):
    permission_classes = [IsVerifiedProfessional]

    @extend_schema(
        request=None,
        responses={200: inline_serializer(
            name="StripeConnectOnboardResponse",
            fields={"url": serializers.URLField()},
        )},
    )
    def post(self, request: Request) -> Response:
        profile = request.user.professional_profile
        url = create_connect_account_link(profile)
        return Response({"url": url}, status=status.HTTP_200_OK)


class StripeWebhookView(APIView):
    permission_classes = [AllowAny]
    authentication_classes: list = []

    @extend_schema(
        request=inline_serializer(
            name="StripeWebhookRequest",
            fields={"payload": serializers.CharField()},
        ),
        responses={200: inline_serializer(
            name="StripeWebhookResponse",
            fields={"status": serializers.CharField()},
        )},
    )
    def post(self, request: Request) -> Response:
        sig_header = request.META.get("HTTP_STRIPE_SIGNATURE", "")
        try:
            result = process_webhook(request.body, sig_header)
        except Exception:
            logger.exception("Stripe webhook error")
            return Response(
                {"error": "Webhook processing failed"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        event_type = result["type"]
        if event_type == "payment_intent.succeeded":
            pi_id = result["data"].get("id", "")
            Payment.objects.filter(stripe_payment_intent_id=pi_id).update(
                status="captured",
            )
        elif event_type == "payment_intent.payment_failed":
            pi_id = result["data"].get("id", "")
            Payment.objects.filter(stripe_payment_intent_id=pi_id).update(
                status="failed",
            )

        return Response({"status": "ok"}, status=status.HTTP_200_OK)


class PaymentDetailView(APIView):
    permission_classes = [IsVerifiedProfessional]

    @extend_schema(
        responses={200: inline_serializer(
            name="PaymentDetailResponse",
            fields={
                "id": serializers.UUIDField(),
                "gig_uuid": serializers.UUIDField(),
                "stripe_payment_intent_id": serializers.CharField(),
                "amount": serializers.DecimalField(max_digits=10, decimal_places=2),
                "platform_fee": serializers.DecimalField(max_digits=10, decimal_places=2),
                "status": serializers.CharField(),
            },
        )},
    )
    def get(self, request: Request, gig_uuid) -> Response:
        try:
            payment = Payment.objects.select_related("gig").get(gig__id=gig_uuid)
        except Payment.DoesNotExist:
            return Response(
                {"error": "Payment not found"},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(
            {
                "id": str(payment.id),
                "gig_uuid": str(payment.gig.id),
                "stripe_payment_intent_id": payment.stripe_payment_intent_id,
                "amount": str(payment.amount),
                "platform_fee": str(payment.platform_fee),
                "status": payment.status,
            },
            status=status.HTTP_200_OK,
        )
