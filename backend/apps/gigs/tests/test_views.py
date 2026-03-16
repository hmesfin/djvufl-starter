"""Tests for gigs app views."""

from datetime import date, timedelta
from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.gigs.models import Gig, GigInvitation, GigStatus, InvitationStatus
from apps.gigs.tests.factories import GigFactory, GigInvitationFactory
from apps.professionals.models import LicenseStatus
from apps.professionals.tests.factories import ProfessionalProfileFactory
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


class TestCreateGig:
    url = reverse("api:gig-list")

    def test_create_gig(self, verified_agent: tuple) -> None:
        """Verified agent creates gig, status defaults to draft."""
        client, user, profile = verified_agent
        data = {
            "title": "Show 123 Main St",
            "description": "Showing for buyer",
            "location_address": "123 Main St, Minneapolis, MN",
            "location_lat": "44.9778",
            "location_lng": "-93.2650",
            "scheduled_date": str(date.today() + timedelta(days=3)),
            "scheduled_time": "14:00:00",
            "budget_range_min": "50.00",
            "budget_range_max": "150.00",
            "gig_type": "showing",
        }
        response = client.post(self.url, data, format="json")

        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["title"] == "Show 123 Main St"
        assert response.data["status"] == GigStatus.DRAFT
        assert Gig.objects.count() == 1

    def test_unverified_cannot_create_gig(self, api_client: APIClient) -> None:
        """Unverified user gets 403."""
        user = UserFactory()
        ProfessionalProfileFactory(
            user=user, license_status=LicenseStatus.PENDING
        )
        api_client.force_authenticate(user=user)
        data = {
            "title": "Show 123 Main St",
            "location_address": "123 Main St",
            "scheduled_date": str(date.today() + timedelta(days=3)),
            "scheduled_time": "14:00:00",
            "gig_type": "showing",
        }
        response = api_client.post(self.url, data, format="json")
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestListGigs:
    url = reverse("api:gig-list")

    def test_list_own_gigs(self, verified_agent: tuple) -> None:
        """Agent sees own posted and assigned gigs."""
        client, user, profile = verified_agent
        own_gig = GigFactory(posted_by=profile)
        assigned_gig = GigFactory(assigned_to=profile)
        GigFactory()  # someone else's gig

        response = client.get(self.url)

        assert response.status_code == status.HTTP_200_OK
        uuids = [r["uuid"] for r in response.data["results"]]
        assert str(own_gig.id) in uuids
        assert str(assigned_gig.id) in uuids
        assert len(uuids) == 2

    def test_list_posted_gigs_marketplace(self, verified_agent: tuple) -> None:
        """marketplace=true shows only POSTED gigs."""
        client, user, profile = verified_agent
        posted_gig = GigFactory(status=GigStatus.POSTED)
        GigFactory(status=GigStatus.DRAFT)  # not visible
        GigFactory(status=GigStatus.ACCEPTED)  # not visible

        response = client.get(self.url, {"marketplace": "true"})

        assert response.status_code == status.HTTP_200_OK
        uuids = [r["uuid"] for r in response.data["results"]]
        assert str(posted_gig.id) in uuids
        assert len(uuids) == 1


class TestGigStatusTransition:
    def test_post_gig(self, verified_agent: tuple) -> None:
        """Transition DRAFT -> POSTED."""
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.DRAFT)
        url = reverse("api:gig-transition", kwargs={"uuid": gig.id})

        response = client.post(url, {"status": "posted"}, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert response.data["status"] == GigStatus.POSTED
        gig.refresh_from_db()
        assert gig.status == GigStatus.POSTED

    def test_cancel_gig(self, verified_agent: tuple) -> None:
        """Transition POSTED -> CANCELLED."""
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.POSTED)
        url = reverse("api:gig-transition", kwargs={"uuid": gig.id})

        response = client.post(url, {"status": "cancelled"}, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert response.data["status"] == GigStatus.CANCELLED

    def test_cannot_transition_others_gig(self, verified_agent: tuple) -> None:
        """Cannot transition a gig you don't own -- returns 404."""
        client, user, profile = verified_agent
        other_gig = GigFactory(status=GigStatus.DRAFT)  # owned by someone else
        url = reverse("api:gig-transition", kwargs={"uuid": other_gig.id})

        response = client.post(url, {"status": "posted"}, format="json")

        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_invalid_transition(self, verified_agent: tuple) -> None:
        """Cannot transition COMPLETED -> POSTED."""
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.COMPLETED)
        url = reverse("api:gig-transition", kwargs={"uuid": gig.id})

        response = client.post(url, {"status": "posted"}, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST


class TestGigInvitations:
    def test_create_invitation(self, verified_agent: tuple) -> None:
        """Gig poster invites a verified agent."""
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.POSTED)
        invitee = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED
        )
        url = reverse("api:gig-invitation-list", kwargs={"gig_uuid": gig.id})

        response = client.post(
            url,
            {
                "invited_agent_uuid": str(invitee.id),
                "message": "Would you like to cover this showing?",
            },
            format="json",
        )

        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["status"] == InvitationStatus.PENDING
        assert GigInvitation.objects.count() == 1

    def test_respond_to_invitation(self, api_client: APIClient) -> None:
        """Invited agent accepts invitation with proposed_rate."""
        invitation = GigInvitationFactory()
        agent_user = invitation.invited_agent.user
        api_client.force_authenticate(user=agent_user)

        url = reverse(
            "api:gig-invitation-detail",
            kwargs={
                "gig_uuid": invitation.gig.id,
                "uuid": invitation.id,
            },
        )

        response = api_client.patch(
            url,
            {
                "status": InvitationStatus.ACCEPTED,
                "proposed_rate": "85.00",
            },
            format="json",
        )

        assert response.status_code == status.HTTP_200_OK
        invitation.refresh_from_db()
        assert invitation.status == InvitationStatus.ACCEPTED
        assert invitation.proposed_rate == Decimal("85.00")

    def test_cannot_invite_to_others_gig(
        self, verified_agent: tuple
    ) -> None:
        """Cannot create invitations for a gig you don't own."""
        client, user, profile = verified_agent
        other_gig = GigFactory(status=GigStatus.POSTED)  # someone else's
        invitee = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED
        )
        url = reverse(
            "api:gig-invitation-list", kwargs={"gig_uuid": other_gig.id}
        )

        response = client.post(
            url,
            {"invited_agent_uuid": str(invitee.id)},
            format="json",
        )

        assert response.status_code == status.HTTP_403_FORBIDDEN
