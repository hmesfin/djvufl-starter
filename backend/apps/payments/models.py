from django.db import models
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel


class PaymentStatus(models.TextChoices):
    PENDING = "pending", _("Pending")
    CAPTURED = "captured", _("Captured")
    RELEASED = "released", _("Released")
    REFUNDED = "refunded", _("Refunded")
    FAILED = "failed", _("Failed")


class Payment(BaseModel):
    gig = models.OneToOneField(
        "gigs.Gig",
        on_delete=models.CASCADE,
        related_name="payment",
        verbose_name=_("gig"),
    )
    stripe_payment_intent_id = models.CharField(
        _("Stripe PaymentIntent ID"),
        max_length=255,
        blank=True,
        default="",
    )
    stripe_transfer_id = models.CharField(
        _("Stripe Transfer ID"),
        max_length=255,
        blank=True,
        default="",
    )
    amount = models.DecimalField(
        _("amount"),
        max_digits=10,
        decimal_places=2,
    )
    platform_fee = models.DecimalField(
        _("platform fee"),
        max_digits=10,
        decimal_places=2,
    )
    status = models.CharField(
        _("status"),
        max_length=20,
        choices=PaymentStatus.choices,
        default=PaymentStatus.PENDING,
    )

    class Meta:
        ordering = ["-created"]
        verbose_name = _("payment")
        verbose_name_plural = _("payments")

    def __str__(self) -> str:
        return f"Payment for {self.gig.title} - ${self.amount} ({self.status})"
