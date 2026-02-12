"""
OTP-related models.
"""

import secrets
from datetime import timedelta
from typing import TYPE_CHECKING

from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel

from .base_otp import BaseOTPModel

if TYPE_CHECKING:
    from .users import User


class EmailVerificationOTP(BaseOTPModel, BaseModel):
    """Model to store OTP codes for email verification."""

    user = models.ForeignKey(
        "users.User",
        on_delete=models.CASCADE,
        related_name="email_otps",
        verbose_name=_("user"),
    )

    class Meta(BaseOTPModel.Meta):
        verbose_name = _("Email Verification OTP")
        verbose_name_plural = _("Email Verification OTPs")
        ordering = ["-created"]
        indexes = [
            models.Index(fields=["user", "-created"]),
        ]

    def __str__(self) -> str:
        return f"OTP for {self.user.email} - {self.code}"

    @classmethod
    def create_for_user(cls, user: "User") -> "EmailVerificationOTP":
        """Create a new OTP for the given user."""
        code = cls.generate_code()
        expires_at = timezone.now() + timedelta(minutes=15)
        return cls.objects.create(user=user, code=code, expires_at=expires_at)


class PasswordResetOTP(BaseOTPModel, BaseModel):
    """Model to store OTP codes for password reset."""

    user = models.ForeignKey(
        "users.User",
        on_delete=models.CASCADE,
        related_name="password_reset_otps",
        verbose_name=_("user"),
    )

    class Meta(BaseOTPModel.Meta):
        verbose_name = _("Password Reset OTP")
        verbose_name_plural = _("Password Reset OTPs")
        ordering = ["-created"]
        indexes = [
            models.Index(fields=["user", "-created"]),
        ]

    def __str__(self) -> str:
        return f"Password Reset OTP for {self.user.email} - {self.code}"

    @classmethod
    def create_for_user(cls, user: "User") -> "PasswordResetOTP":
        """Create a new OTP for the given user and invalidate old ones."""
        # Mark all existing unused OTPs for this user as used
        cls.objects.filter(user=user, is_used=False).update(is_used=True)

        # Create new OTP
        code = cls.generate_code()
        expires_at = timezone.now() + timedelta(minutes=15)
        return cls.objects.create(user=user, code=code, expires_at=expires_at)


class PasswordResetToken(BaseModel):
    """Model to store password reset tokens."""

    user = models.ForeignKey(
        "users.User",
        on_delete=models.CASCADE,
        related_name="password_reset_tokens",
        verbose_name=_("user"),
    )
    token = models.CharField(_("reset token"), max_length=64, unique=True)
    expires_at = models.DateTimeField(_("expires at"))
    is_used = models.BooleanField(_("is used"), default=False)

    class Meta:
        verbose_name = _("Password Reset Token")
        verbose_name_plural = _("Password Reset Tokens")
        ordering = ["-created"]
        indexes = [
            models.Index(fields=["user", "-created"]),
            models.Index(fields=["token", "is_used"]),
        ]

    def __str__(self) -> str:
        return f"Password reset for {self.user.email}"

    @classmethod
    def generate_token(cls) -> str:
        """Generate a secure random token."""
        return secrets.token_urlsafe(32)

    @classmethod
    def create_for_user(cls, user: "User") -> "PasswordResetToken":
        """Create a new password reset token for the given user."""
        token = cls.generate_token()
        expires_at = timezone.now() + timedelta(hours=1)
        return cls.objects.create(user=user, token=token, expires_at=expires_at)

    def is_valid(self) -> bool:
        """Check if the token is still valid."""
        return not self.is_used and self.expires_at > timezone.now()

    def mark_as_used(self) -> None:
        """Mark the token as used."""
        self.is_used = True
        self.save(update_fields=["is_used", "modified"])
