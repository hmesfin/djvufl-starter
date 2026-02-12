"""Authentication-related serializers."""

from typing import Any

from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from apps.users.models import User


class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom JWT serializer that uses email and checks email verification."""

    username_field = "email"

    def validate(self, attrs: dict[str, Any]) -> dict[str, Any]:
        """Validate credentials and check email verification."""
        # Call parent validation (checks credentials and sets self.user)
        data = super().validate(attrs)

        # Type guard: parent validation guarantees user is set
        if self.user is None:
            raise serializers.ValidationError(
                _("Authentication failed."),
            )

        # Check if email is verified
        if not self.user.is_email_verified:
            # OTP creation is handled in the view to avoid transaction rollback issues
            raise serializers.ValidationError(
                {
                    "email": _(
                        "Email address is not verified. "
                        "We've sent a verification code to your email. "
                        "Please verify your email before logging in.",
                    ),
                    "email_verification_required": True,
                },
            )

        return data


class PasswordChangeSerializer(serializers.Serializer):
    """Serializer for changing password (authenticated users)."""

    old_password = serializers.CharField(
        required=True,
        write_only=True,
        style={"input_type": "password"},
    )
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        style={"input_type": "password"},
    )

    def validate_new_password(self, value: str) -> str:
        """Validate new password using Django's password validators."""

        validate_password(value)
        return value

    def validate_old_password(self, value: str) -> str:
        """Validate that old password is correct."""
        user = self.context["request"].user
        if not user.check_password(value):
            msg = _("Incorrect password.")
            raise serializers.ValidationError(msg)
        return value

    def save(self, **kwargs: Any) -> User:
        """Change user password."""
        user = self.context["request"].user
        new_password = self.validated_data["new_password"]

        user.set_password(new_password)
        user.save(update_fields=["password", "modified"])

        return user
