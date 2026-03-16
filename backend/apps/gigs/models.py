from django.db import models
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel


class GigStatus(models.TextChoices):
    DRAFT = "draft", _("Draft")
    POSTED = "posted", _("Posted")
    INVITED = "invited", _("Invited")
    NEGOTIATING = "negotiating", _("Negotiating")
    ACCEPTED = "accepted", _("Accepted")
    IN_PROGRESS = "in_progress", _("In Progress")
    COMPLETED = "completed", _("Completed")
    CANCELLED = "cancelled", _("Cancelled")
    DISPUTED = "disputed", _("Disputed")


class GigType(models.TextChoices):
    SHOWING = "showing", _("Showing")
    OPEN_HOUSE = "open_house", _("Open House")
    INSPECTION = "inspection_accompaniment", _("Inspection Accompaniment")
    OTHER = "other", _("Other")


class InvitationStatus(models.TextChoices):
    PENDING = "pending", _("Pending")
    ACCEPTED = "accepted", _("Accepted")
    DECLINED = "declined", _("Declined")
    WITHDRAWN = "withdrawn", _("Withdrawn")


class Gig(BaseModel):
    posted_by = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="posted_gigs",
        verbose_name=_("posted by"),
    )
    assigned_to = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_gigs",
        verbose_name=_("assigned to"),
    )
    title = models.CharField(_("title"), max_length=255)
    description = models.TextField(_("description"), blank=True)
    location_address = models.CharField(_("location address"), max_length=500)
    location_lat = models.DecimalField(
        _("location latitude"),
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
    )
    location_lng = models.DecimalField(
        _("location longitude"),
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
    )
    service_area = models.ForeignKey(
        "professionals.ServiceArea",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="gigs",
        verbose_name=_("service area"),
    )
    scheduled_date = models.DateField(_("scheduled date"))
    scheduled_time = models.TimeField(_("scheduled time"))
    budget_range_min = models.DecimalField(
        _("budget range minimum"),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )
    budget_range_max = models.DecimalField(
        _("budget range maximum"),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )
    agreed_price = models.DecimalField(
        _("agreed price"),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )
    status = models.CharField(
        _("status"),
        max_length=20,
        choices=GigStatus.choices,
        default=GigStatus.DRAFT,
    )
    gig_type = models.CharField(
        _("gig type"),
        max_length=30,
        choices=GigType.choices,
        default=GigType.SHOWING,
    )

    class Meta:
        ordering = ["-created"]
        verbose_name = _("gig")
        verbose_name_plural = _("gigs")
        indexes = [
            models.Index(fields=["status"]),
            models.Index(fields=["posted_by", "status"]),
            models.Index(fields=["assigned_to", "status"]),
            models.Index(fields=["scheduled_date"]),
            models.Index(fields=["service_area"]),
        ]

    def __str__(self) -> str:
        return self.title


class GigInvitation(BaseModel):
    gig = models.ForeignKey(
        Gig,
        on_delete=models.CASCADE,
        related_name="invitations",
        verbose_name=_("gig"),
    )
    invited_agent = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="gig_invitations",
        verbose_name=_("invited agent"),
    )
    proposed_rate = models.DecimalField(
        _("proposed rate"),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
    )
    message = models.TextField(_("message"), blank=True)
    status = models.CharField(
        _("status"),
        max_length=20,
        choices=InvitationStatus.choices,
        default=InvitationStatus.PENDING,
    )

    class Meta:
        unique_together = ["gig", "invited_agent"]
        ordering = ["-created"]
        verbose_name = _("gig invitation")
        verbose_name_plural = _("gig invitations")

    def __str__(self) -> str:
        return f"Invitation for {self.gig.title} to {self.invited_agent}"
