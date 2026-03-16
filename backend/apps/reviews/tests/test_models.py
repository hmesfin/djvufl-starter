"""Tests for reviews app models."""

import uuid
from decimal import Decimal

import pytest
from django.core.exceptions import ValidationError
from django.db import IntegrityError

from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.reviews.models import Review
from apps.reviews.tests.factories import ReviewFactory


@pytest.mark.django_db
class TestReview:
    def test_create_review(self):
        review = ReviewFactory()
        assert review.pk is not None
        assert isinstance(review.pk, uuid.UUID)
        assert review.rating == 5
        assert review.is_from_poster is True

    def test_str(self):
        review = ReviewFactory()
        expected = f"Review by {review.reviewer} for {review.reviewee} ({review.rating}/5)"
        assert str(review) == expected

    def test_has_timestamps(self):
        review = ReviewFactory()
        assert review.created is not None
        assert review.modified is not None

    def test_has_soft_delete(self):
        review = ReviewFactory()
        assert review.is_deleted is False

    def test_rating_range(self):
        """Rating below 1 or above 5 should fail validation."""
        fk_exclude = {"gig", "reviewer", "reviewee"}

        review = ReviewFactory.build(rating=0)
        with pytest.raises(ValidationError):
            review.full_clean(exclude=fk_exclude)

        review = ReviewFactory.build(rating=6)
        with pytest.raises(ValidationError):
            review.full_clean(exclude=fk_exclude)

        # Valid boundaries
        review = ReviewFactory.build(rating=1)
        review.full_clean(exclude=fk_exclude)  # should not raise
        review = ReviewFactory.build(rating=5)
        review.full_clean(exclude=fk_exclude)  # should not raise

    def test_one_review_per_direction_per_gig(self):
        """unique_together on (gig, reviewer, reviewee)."""
        review = ReviewFactory()
        with pytest.raises(IntegrityError):
            ReviewFactory(
                gig=review.gig,
                reviewer=review.reviewer,
                reviewee=review.reviewee,
            )

    def test_update_average_rating(self):
        """Creating reviews updates the reviewee's average_rating."""
        reviewee = ProfessionalProfileFactory(license_status="verified")
        ReviewFactory(reviewee=reviewee, rating=4)
        reviewee.refresh_from_db()
        assert reviewee.average_rating == Decimal("4.00")

        ReviewFactory(reviewee=reviewee, rating=2)
        reviewee.refresh_from_db()
        assert reviewee.average_rating == Decimal("3.00")

    def test_comment_blank(self):
        review = ReviewFactory(comment="")
        assert review.comment == ""

    def test_ordering(self):
        r1 = ReviewFactory()
        r2 = ReviewFactory()
        reviews = list(Review.objects.all())
        assert reviews[0] == r2
        assert reviews[1] == r1

    def test_gig_cascade_delete(self):
        review = ReviewFactory()
        gig = review.gig
        gig.delete()
        assert not Review.objects.filter(pk=review.pk).exists()

    def test_reviewer_cascade_delete(self):
        review = ReviewFactory()
        reviewer = review.reviewer
        reviewer.delete()
        assert not Review.objects.filter(pk=review.pk).exists()
