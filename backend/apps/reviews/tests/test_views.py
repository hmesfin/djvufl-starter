"""Tests for reviews app views."""

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.gigs.models import GigStatus
from apps.gigs.tests.factories import GigFactory
from apps.professionals.models import LicenseStatus
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.reviews.models import Review
from apps.reviews.tests.factories import ReviewFactory
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


@pytest.fixture()
def api_client() -> APIClient:
    return APIClient()


@pytest.fixture()
def verified_agent(api_client: APIClient) -> tuple[APIClient, object, object]:
    """Return (authenticated client, user, verified professional profile)."""
    user = UserFactory()
    profile = ProfessionalProfileFactory(
        user=user, license_status=LicenseStatus.VERIFIED
    )
    api_client.force_authenticate(user=user)
    return api_client, user, profile


class TestCreateReview:
    url = reverse("api:review-create")

    def test_create_review_as_poster(self, verified_agent: tuple) -> None:
        """Poster can review the assignee on a completed gig."""
        client, user, profile = verified_agent
        assignee = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        gig = GigFactory(
            posted_by=profile,
            assigned_to=assignee,
            status=GigStatus.COMPLETED,
        )

        response = client.post(
            self.url,
            {"gig_uuid": str(gig.id), "rating": 5, "comment": "Great work!"},
            format="json",
        )

        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["rating"] == 5
        assert response.data["comment"] == "Great work!"
        assert response.data["is_from_poster"] is True
        assert Review.objects.count() == 1

    def test_create_review_as_assignee(self, api_client: APIClient) -> None:
        """Assignee can review the poster on a completed gig."""
        assignee_user = UserFactory()
        assignee = ProfessionalProfileFactory(
            user=assignee_user, license_status=LicenseStatus.VERIFIED
        )
        poster = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        gig = GigFactory(
            posted_by=poster,
            assigned_to=assignee,
            status=GigStatus.COMPLETED,
        )
        api_client.force_authenticate(user=assignee_user)

        response = api_client.post(
            self.url,
            {"gig_uuid": str(gig.id), "rating": 4},
            format="json",
        )

        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["is_from_poster"] is False
        review = Review.objects.first()
        assert review is not None
        assert review.reviewer == assignee
        assert review.reviewee == poster

    def test_cannot_review_non_participant(self, verified_agent: tuple) -> None:
        """A non-participant gets 403."""
        client, user, profile = verified_agent
        poster = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        assignee = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        gig = GigFactory(
            posted_by=poster,
            assigned_to=assignee,
            status=GigStatus.COMPLETED,
        )

        response = client.post(
            self.url,
            {"gig_uuid": str(gig.id), "rating": 3},
            format="json",
        )

        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_cannot_review_non_completed_gig(self, verified_agent: tuple) -> None:
        """Can only review completed gigs."""
        client, user, profile = verified_agent
        assignee = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        gig = GigFactory(
            posted_by=profile,
            assigned_to=assignee,
            status=GigStatus.IN_PROGRESS,
        )

        response = client.post(
            self.url,
            {"gig_uuid": str(gig.id), "rating": 5},
            format="json",
        )

        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestProfessionalReviewList:
    def test_list_reviews_for_agent(self, verified_agent: tuple) -> None:
        """List reviews received by a specific professional."""
        client, user, profile = verified_agent
        target = ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        ReviewFactory(reviewee=target, rating=5)
        ReviewFactory(reviewee=target, rating=4)
        ReviewFactory()  # unrelated review

        url = reverse("api:professional-reviews", kwargs={"uuid": target.id})
        response = client.get(url)

        assert response.status_code == status.HTTP_200_OK
        assert len(response.data["results"]) == 2
