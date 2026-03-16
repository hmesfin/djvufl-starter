from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.db.models import Avg
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel


class Review(BaseModel):
    gig = models.ForeignKey(
        "gigs.Gig",
        on_delete=models.CASCADE,
        related_name="reviews",
        verbose_name=_("gig"),
    )
    reviewer = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="reviews_given",
        verbose_name=_("reviewer"),
    )
    reviewee = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="reviews_received",
        verbose_name=_("reviewee"),
    )
    rating = models.IntegerField(
        _("rating"),
        validators=[MinValueValidator(1), MaxValueValidator(5)],
    )
    comment = models.TextField(_("comment"), blank=True)
    is_from_poster = models.BooleanField(_("is from poster"))

    class Meta:
        ordering = ["-created"]
        unique_together = ["gig", "reviewer", "reviewee"]
        verbose_name = _("review")
        verbose_name_plural = _("reviews")

    def __str__(self) -> str:
        return f"Review by {self.reviewer} for {self.reviewee} ({self.rating}/5)"

    def save(self, *args, **kwargs) -> None:
        super().save(*args, **kwargs)
        self._update_reviewee_rating()

    def _update_reviewee_rating(self) -> None:
        avg = Review.objects.filter(reviewee=self.reviewee).aggregate(
            avg_rating=Avg("rating")
        )["avg_rating"]
        self.reviewee.average_rating = avg
        self.reviewee.save(update_fields=["average_rating"])
