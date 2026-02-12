"""OTP-related serializers."""

from typing import Any

from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from apps.users.models import EmailVerificationOTP
from apps.users.models import User
from apps.users.tasks import send_otp_email


class OTPVerificationSerializer(serializers.Serializer):
    """Serializer for OTP email verification."""

    email = serializers.EmailField(required=True)
    code = serializers.CharField(required=True, max_length=6, min_length=6)

    def validate(self, attrs: dict[str, Any]) -> dict[str, Any]:
        """Validate OTP code for the given email."""
        email = attrs.get("email", "").lower()
        code = attrs.get("code", "")

        # Check if user exists
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            msg = _("Invalid email or verification code.")
            raise serializers.ValidationError(
                msg,
            ) from None

        # Find the most recent valid OTP for this user

        otp = (
            EmailVerificationOTP.objects.filter(
                user=user,
                code=code,
                is_used=False,
            )
            .order_by("-created")
            .first()
        )

        if not otp:
            msg = _("Invalid email or verification code.")
            raise serializers.ValidationError(
                msg,
            )

        if not otp.is_valid():
            msg = _("Verification code has expired or is invalid.")
            raise serializers.ValidationError(
                msg,
            )

        # Store user and OTP for use in the view
        attrs["user"] = user
        attrs["otp"] = otp

        return attrs


class ResendOTPSerializer(serializers.Serializer):
    """Serializer for resending OTP to unverified email."""

    email = serializers.EmailField(required=True)

    def validate_email(self, value: str) -> str:
        """Validate and normalize email."""
        return value.lower()

    def save(self) -> None:
        """Create new OTP and send email."""
        email = self.validated_data["email"]

        # Try to get user (security: don't leak user existence)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # For security, return success even if user doesn't exist
            # This prevents email enumeration attacks
            return

        # Check if email is already verified
        if user.is_email_verified:
            msg = _("Email address is already verified.")
            raise serializers.ValidationError(msg)

        # Create new OTP

        otp = EmailVerificationOTP.create_for_user(user)

        # Send OTP email via Celery task
        send_otp_email.delay(user.id, otp.code)
