from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail


@shared_task
def send_verification_status_email(profile_id: int, status: str) -> None:
    from apps.professionals.models import ProfessionalProfile

    profile = ProfessionalProfile.objects.select_related("user").get(pk=profile_id)

    if status == "verified":
        subject = "Your RealGig Profile Has Been Verified!"
        message = (
            f"Hi {profile.user.first_name},\n\n"
            "Your real estate license has been verified. "
            "You can now post gigs, accept invitations, and message other agents.\n\n"
            "Welcome to RealGig!"
        )
    elif status == "rejected":
        subject = "RealGig Verification Update"
        message = (
            f"Hi {profile.user.first_name},\n\n"
            "We were unable to verify your real estate license. "
            f"Reason: {profile.rejection_reason or 'Please contact support for details.'}\n\n"
            "If you believe this is an error, please contact support."
        )
    else:
        return

    send_mail(
        subject=subject,
        message=message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[profile.user.email],
    )
