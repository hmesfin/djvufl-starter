"""Password reset-related serializers."""

from typing import Any

from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from apps.users.models import PasswordResetToken
from apps.users.models import User
from apps.users.tasks import send_password_reset_email
from apps.users.tasks import send_password_reset_otp_email


class PasswordResetRequestSerializer(serializers.Serializer):
    """Serializer for password reset request."""

    email = serializers.EmailField(required=True)

    def validate_email(self, value: str) -> str:
        """Validate and normalize email."""
        return value.lower()

    def save(self) -> None:
        """Create password reset token and send email."""
        email = self.validated_data["email"]

        # Try to get user (security: don't leak user existence)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # For security, return success even if user doesn't exist
            # This prevents email enumeration attacks
            return

        # Create new password reset token

        token = PasswordResetToken.create_for_user(user)

        # Send password reset email via Celery task
        send_password_reset_email.delay(user.id, token.token)


class PasswordResetConfirmSerializer(serializers.Serializer):
    """Serializer for password reset confirmation."""

    token = serializers.CharField(required=True, max_length=64)
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
    )

    def validate_password(self, value: str) -> str:
        """Validate password using Django's password validators."""
        validate_password(value)
        return value

    def validate(self, attrs: dict[str, Any]) -> dict[str, Any]:
        """Validate token and prepare for password reset."""
        token_str = attrs.get("token", "")

        # Find valid token
        try:
            token = PasswordResetToken.objects.get(
                token=token_str,
                is_used=False,
            )
        except PasswordResetToken.DoesNotExist:
            msg = _("Invalid or expired password reset token.")
            raise serializers.ValidationError(
                msg,
            ) from None

        # Check if token is still valid (not expired)
        if not token.is_valid():
            msg = _("Invalid or expired password reset token.")
            raise serializers.ValidationError(
                msg,
            )

        # Store token and user for use in save()
        attrs["reset_token"] = token
        attrs["user"] = token.user

        return attrs

    def save(self) -> User:
        """Reset user password and mark token as used."""
        user = self.validated_data["user"]
        reset_token = self.validated_data["reset_token"]
        new_password = self.validated_data["password"]

        # Set new password
        user.set_password(new_password)
        user.save(update_fields=["password", "modified"])

        # Mark token as used
        reset_token.mark_as_used()

        return user


class PasswordResetOTPRequestSerializer(serializers.Serializer):
    """Serializer for OTP-based password reset request."""

    email = serializers.EmailField(required=True)

    def validate_email(self, value: str) -> str:
        """Validate and normalize email."""
        return value.lower()

    def save(self) -> None:
        """Create password reset OTP and send email."""
        email = self.validated_data["email"]

        # Try to get user (security: don't leak user existence)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # For security, return success even if user doesn't exist
            # This prevents email enumeration attacks
            return

        # Create new password reset OTP (invalidates old ones)
        from apps.users.models import PasswordResetOTP  # noqa: PLC0415

        otp = PasswordResetOTP.create_for_user(user)

        # Send password reset OTP email via Celery task
        send_password_reset_otp_email.delay(user.id, otp.code)


class PasswordResetOTPConfirmSerializer(serializers.Serializer):
    """Serializer for OTP-based password reset confirmation."""

    email = serializers.EmailField(required=True)
    code = serializers.CharField(required=True, max_length=6, min_length=6)
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
    )

    def validate_email(self, value: str) -> str:
        """Validate and normalize email."""
        return value.lower()

    def validate_password(self, value: str) -> str:
        """Validate password using Django's password validators."""
        validate_password(value)
        return value

    def validate(self, attrs: dict[str, Any]) -> dict[str, Any]:
        """Validate OTP code and prepare for password reset."""
        email = attrs.get("email", "")
        code = attrs.get("code", "")

        # Get user by email
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            msg = _("Invalid email or code.")
            raise serializers.ValidationError(msg) from None

        # Find valid OTP for this user
        try:
            from apps.users.models import PasswordResetOTP  # noqa: PLC0415

            otp = PasswordResetOTP.objects.get(
                user=user,
                code=code,
                is_used=False,
            )
        except PasswordResetOTP.DoesNotExist:
            msg = _("Invalid or expired OTP code.")
            raise serializers.ValidationError(msg) from None

        # Check if OTP is still valid (not expired)
        if not otp.is_valid():
            msg = _("OTP code has expired. Please request a new one.")
            raise serializers.ValidationError(msg)

        # Store OTP and user in validated_data for save method
        attrs["_otp"] = otp
        attrs["_user"] = user

        return attrs

    def save(self, **kwargs: Any) -> User:
        """Reset user password and mark OTP as used."""
        user = self.validated_data["_user"]
        otp = self.validated_data["_otp"]
        new_password = self.validated_data["password"]

        # Update password
        user.set_password(new_password)
        user.save(update_fields=["password", "modified"])

        # Mark OTP as used
        otp.mark_as_used()

        return user
