"""
Base OTP model functionality to eliminate code duplication.
"""

import secrets

from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _


class BaseOTPModel(models.Model):
    """
    Abstract base model for OTP functionality.

    Contains common methods and fields shared by all OTP types.
    """

    code = models.CharField(_("OTP code"), max_length=6)
    expires_at = models.DateTimeField(_("expires at"))
    is_used = models.BooleanField(_("is used"), default=False)

    class Meta:
        abstract = True
        ordering = ["-created"]
        indexes = [
            models.Index(fields=["code", "is_used"]),
        ]

    @classmethod
    def generate_code(cls) -> str:
        """Generate a 6-digit OTP code."""
        return str(secrets.randbelow(1000000)).zfill(6)

    def is_valid(self) -> bool:
        """Check if the OTP is still valid."""
        return not self.is_used and self.expires_at > timezone.now()

    def mark_as_used(self) -> None:
        """Mark the OTP as used."""
        self.is_used = True
        self.save(update_fields=["is_used", "modified"])


class EmailValidationMixin:
    """
    Mixin for common email validation functionality in serializers.
    """

    def validate_and_normalize_email(self, value: str) -> str:
        """Validate and normalize email to lowercase."""
        return value.lower()

    def get_user_or_none(self, email: str):
        """
        Get user by email or return None.

        This method is designed to prevent email enumeration attacks
        by not raising exceptions when user doesn't exist.
        """

        from apps.users.models import User  # noqa: PLC0415

        try:
            return User.objects.get(email=email.lower())
        except User.DoesNotExist:
            return None
