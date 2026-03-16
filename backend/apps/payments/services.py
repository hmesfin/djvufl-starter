import stripe
from decimal import Decimal

from django.conf import settings

stripe.api_key = settings.STRIPE_SECRET_KEY


def create_connect_account_link(profile) -> str:
    """Create Stripe Connect onboarding link."""
    if not profile.stripe_connect_account_id:
        account = stripe.Account.create(
            type="express",
            email=profile.user.email,
            metadata={"profile_uuid": str(profile.id)},
        )
        profile.stripe_connect_account_id = account.id
        profile.save(update_fields=["stripe_connect_account_id"])

    link = stripe.AccountLink.create(
        account=profile.stripe_connect_account_id,
        refresh_url=f"{settings.FRONTEND_URL}/settings/stripe/refresh",
        return_url=f"{settings.FRONTEND_URL}/settings/stripe/complete",
        type="account_onboarding",
    )
    return link.url


def create_payment_intent(gig) -> stripe.PaymentIntent:
    """Create PaymentIntent when gig is accepted."""
    from apps.payments.models import Payment

    amount_cents = int(gig.agreed_price * 100)
    fee_percent = Decimal(str(settings.STRIPE_PLATFORM_FEE_PERCENT))
    platform_fee = gig.agreed_price * fee_percent
    fee_cents = int(platform_fee * 100)

    intent = stripe.PaymentIntent.create(
        amount=amount_cents,
        currency="usd",
        payment_method_types=["card"],
        application_fee_amount=fee_cents,
        transfer_data={"destination": gig.assigned_to.stripe_connect_account_id},
        metadata={"gig_uuid": str(gig.id)},
    )

    Payment.objects.create(
        gig=gig,
        stripe_payment_intent_id=intent.id,
        amount=gig.agreed_price,
        platform_fee=platform_fee,
        status="pending",
    )
    return intent


def process_webhook(payload: bytes, sig_header: str) -> dict:
    """Process Stripe webhook."""
    event = stripe.Webhook.construct_event(
        payload,
        sig_header,
        settings.STRIPE_WEBHOOK_SECRET,
    )
    return {"type": event.type, "data": event.data.object}
