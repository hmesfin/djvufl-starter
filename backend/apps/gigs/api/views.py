"""Views for the gigs app."""

from typing import cast

from django.db.models import Q, QuerySet
from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.gigs.models import Gig, GigInvitation, GigStatus
from apps.users.models import User

from .permissions import IsVerifiedProfessional
from .serializers import (
    GigCreateSerializer,
    GigInvitationCreateSerializer,
    GigInvitationSerializer,
    GigSerializer,
    GigStatusTransitionSerializer,
)


class GigListCreateView(generics.ListCreateAPIView):
    """List and create gigs."""

    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return GigCreateSerializer
        return GigSerializer

    def get_queryset(self) -> QuerySet[Gig]:
        qs = Gig.objects.select_related(
            "posted_by__user", "assigned_to__user"
        )
        marketplace = self.request.query_params.get("marketplace")
        if marketplace == "true":
            return qs.filter(status=GigStatus.POSTED)
        user = cast(User, self.request.user)
        profile = user.professional_profile
        return qs.filter(Q(posted_by=profile) | Q(assigned_to=profile))

    def create(self, request: Request, *args, **kwargs) -> Response:
        serializer = GigCreateSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        gig = serializer.save()
        gig = (
            Gig.objects.select_related("posted_by__user", "assigned_to__user")
            .get(pk=gig.pk)
        )
        return Response(
            GigSerializer(gig).data, status=status.HTTP_201_CREATED
        )


class GigDetailView(generics.RetrieveUpdateAPIView):
    """Retrieve and update a gig."""

    serializer_class = GigSerializer
    permission_classes = [IsVerifiedProfessional]
    lookup_field = "id"
    lookup_url_kwarg = "uuid"

    def get_queryset(self) -> QuerySet[Gig]:
        return Gig.objects.select_related(
            "posted_by__user", "assigned_to__user"
        )


class GigStatusTransitionView(APIView):
    """Transition a gig's status (owner only)."""

    permission_classes = [IsVerifiedProfessional]

    @extend_schema(
        request=GigStatusTransitionSerializer,
        responses={200: GigSerializer},
    )
    def post(self, request: Request, uuid: str) -> Response:
        user = cast(User, request.user)
        profile = user.professional_profile
        try:
            gig = Gig.objects.select_related(
                "posted_by__user", "assigned_to__user"
            ).get(id=uuid, posted_by=profile)
        except Gig.DoesNotExist:
            return Response(
                {"detail": "Not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = GigStatusTransitionSerializer(
            data=request.data, context={"gig": gig}
        )
        serializer.is_valid(raise_exception=True)
        gig.status = serializer.validated_data["status"]
        gig.save()
        return Response(GigSerializer(gig).data)


class GigInvitationListCreateView(generics.ListCreateAPIView):
    """List and create invitations for a gig."""

    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return GigInvitationCreateSerializer
        return GigInvitationSerializer

    def get_queryset(self) -> QuerySet[GigInvitation]:
        return GigInvitation.objects.filter(
            gig__id=self.kwargs["gig_uuid"]
        ).select_related("invited_agent__user")

    def create(self, request: Request, *args, **kwargs) -> Response:
        gig_uuid = self.kwargs["gig_uuid"]
        try:
            gig = Gig.objects.get(id=gig_uuid)
        except Gig.DoesNotExist:
            return Response(
                {"detail": "Gig not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        user = cast(User, request.user)
        profile = user.professional_profile
        if gig.posted_by != profile:
            return Response(
                {"detail": "Only the gig poster can create invitations."},
                status=status.HTTP_403_FORBIDDEN,
            )
        serializer = GigInvitationCreateSerializer(
            data=request.data, context={"request": request, "gig": gig}
        )
        serializer.is_valid(raise_exception=True)
        invitation = serializer.save()
        invitation = (
            GigInvitation.objects.select_related("invited_agent__user")
            .get(pk=invitation.pk)
        )
        return Response(
            GigInvitationSerializer(invitation).data,
            status=status.HTTP_201_CREATED,
        )


class GigInvitationDetailView(generics.RetrieveUpdateAPIView):
    """View and respond to a gig invitation."""

    serializer_class = GigInvitationSerializer
    permission_classes = [IsVerifiedProfessional]
    lookup_field = "id"
    lookup_url_kwarg = "uuid"

    def get_queryset(self) -> QuerySet[GigInvitation]:
        return GigInvitation.objects.filter(
            gig__id=self.kwargs["gig_uuid"]
        ).select_related("invited_agent__user")
