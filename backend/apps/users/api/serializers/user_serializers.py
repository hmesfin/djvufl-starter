"""User-related serializers."""

from typing import Any

from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from apps.users.models import EmailVerificationOTP
from apps.users.models import User
from apps.users.tasks import send_otp_email


class UserSerializer(serializers.ModelSerializer[User]):
    """Serializer for user model."""

    class Meta:
        model = User
        fields = ["first_name", "last_name", "email", "url", "avatar"]

        extra_kwargs = {
            "url": {"view_name": "api:user-detail", "lookup_field": "pk"},
            "avatar": {"required": False, "allow_null": True},
        }


class UserRegistrationSerializer(serializers.ModelSerializer[User]):
    """Serializer for user registration with password validation."""

    password = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
    )

    class Meta:
        model = User
        fields = ["email", "password", "first_name", "last_name"]
        extra_kwargs = {
            "email": {"required": True},
            "first_name": {"required": True},
            "last_name": {"required": True},
        }

    def validate_password(self, value: str) -> str:
        """Validate password using Django's password validators."""
        validate_password(value)
        return value

    def validate_email(self, value: str) -> str:
        """Validate email is unique and normalize it."""
        # Normalize email to lowercase
        value = value.lower()

        # Check if email already exists
        if User.objects.filter(email=value).exists():
            msg = "A user with this email address already exists."
            raise serializers.ValidationError(
                msg,
            )

        return value

    def create(self, validated_data: dict[str, Any]) -> User:
        """Create user with hashed password and generate OTP."""
        # Extract password from validated data
        password = validated_data.pop("password")

        # Create user with is_email_verified=False
        user = User.objects.create_user(
            password=password,
            is_email_verified=False,
            **validated_data,
        )

        # Generate OTP for email verification

        otp = EmailVerificationOTP.create_for_user(user)

        # Send OTP email via Celery task (async)
        send_otp_email.delay(user.id, otp.code)

        return user
