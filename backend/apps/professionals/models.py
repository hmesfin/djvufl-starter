from django.conf import settings
from django.contrib.postgres.fields import ArrayField
from django.db import models
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel


class LicenseStatus(models.TextChoices):
    PENDING = "pending_verification", _("Pending Verification")
    VERIFIED = "verified", _("Verified")
    REJECTED = "rejected", _("Rejected")
    EXPIRED = "expired", _("Expired")


class Specialization(models.TextChoices):
    RESIDENTIAL = "residential", _("Residential")
    COMMERCIAL = "commercial", _("Commercial")
    BUYERS_AGENT = "buyers_agent", _("Buyer's Agent")
    LISTING_AGENT = "listing_agent", _("Listing Agent")


class Metro(BaseModel):
    name = models.CharField(_("name"), max_length=255)
    state = models.CharField(_("state"), max_length=2)

    class Meta:
        unique_together = ["name", "state"]
        ordering = ["state", "name"]
        verbose_name = _("metro")
        verbose_name_plural = _("metros")

    def __str__(self) -> str:
        return f"{self.name}, {self.state}"


class ServiceArea(BaseModel):
    name = models.CharField(_("name"), max_length=255)
    zip_codes = ArrayField(
        models.CharField(max_length=10),
        verbose_name=_("zip codes"),
        default=list,
        blank=True,
    )
    metro = models.ForeignKey(
        Metro,
        on_delete=models.CASCADE,
        related_name="service_areas",
        verbose_name=_("metro"),
    )

    class Meta:
        unique_together = ["name", "metro"]
        ordering = ["name"]
        verbose_name = _("service area")
        verbose_name_plural = _("service areas")

    def __str__(self) -> str:
        return self.name


class ProfessionalProfile(BaseModel):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="professional_profile",
        verbose_name=_("user"),
    )
    license_number = models.CharField(
        _("license number"),
        max_length=50,
        unique=True,
    )
    license_status = models.CharField(
        _("license status"),
        max_length=25,
        choices=LicenseStatus.choices,
        default=LicenseStatus.PENDING,
    )
    license_expiry = models.DateField(
        _("license expiry"),
        null=True,
        blank=True,
    )
    service_areas = models.ManyToManyField(
        ServiceArea,
        related_name="professionals",
        verbose_name=_("service areas"),
        blank=True,
    )
    specializations = ArrayField(
        models.CharField(max_length=25, choices=Specialization.choices),
        verbose_name=_("specializations"),
        default=list,
        blank=True,
    )
    bio = models.TextField(_("bio"), blank=True, default="")
    average_rating = models.DecimalField(
        _("average rating"),
        max_digits=3,
        decimal_places=2,
        null=True,
        blank=True,
    )
    average_response_time = models.DurationField(
        _("average response time"),
        null=True,
        blank=True,
    )
    is_available = models.BooleanField(_("is available"), default=True)
    stripe_connect_account_id = models.CharField(
        _("Stripe Connect account ID"),
        max_length=255,
        blank=True,
        default="",
    )
    verified_at = models.DateTimeField(
        _("verified at"),
        null=True,
        blank=True,
    )
    verified_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="verifications_performed",
        verbose_name=_("verified by"),
    )
    last_reverification_check = models.DateTimeField(
        _("last reverification check"),
        null=True,
        blank=True,
    )
    rejection_reason = models.TextField(
        _("rejection reason"),
        blank=True,
        default="",
    )

    class Meta:
        verbose_name = _("professional profile")
        verbose_name_plural = _("professional profiles")
        indexes = [
            models.Index(fields=["license_status"]),
            models.Index(fields=["is_available"]),
            models.Index(fields=["license_number"]),
        ]

    @property
    def is_verified(self) -> bool:
        return self.license_status == LicenseStatus.VERIFIED

    def __str__(self) -> str:
        return f"{self.user.first_name} {self.user.last_name}"
