import uuid
from datetime import date, time, timedelta
from decimal import Decimal

import pytest
from django.db import IntegrityError

from apps.gigs.models import (
    Gig,
    GigInvitation,
    GigStatus,
    GigType,
    InvitationStatus,
)
from apps.gigs.tests.factories import GigFactory, GigInvitationFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory


@pytest.mark.django_db
class TestGigStatus:
    def test_choices(self):
        assert GigStatus.DRAFT == "draft"
        assert GigStatus.POSTED == "posted"
        assert GigStatus.INVITED == "invited"
        assert GigStatus.NEGOTIATING == "negotiating"
        assert GigStatus.ACCEPTED == "accepted"
        assert GigStatus.IN_PROGRESS == "in_progress"
        assert GigStatus.COMPLETED == "completed"
        assert GigStatus.CANCELLED == "cancelled"
        assert GigStatus.DISPUTED == "disputed"


@pytest.mark.django_db
class TestGigType:
    def test_choices(self):
        assert GigType.SHOWING == "showing"
        assert GigType.OPEN_HOUSE == "open_house"
        assert GigType.INSPECTION == "inspection_accompaniment"
        assert GigType.OTHER == "other"


@pytest.mark.django_db
class TestInvitationStatus:
    def test_choices(self):
        assert InvitationStatus.PENDING == "pending"
        assert InvitationStatus.ACCEPTED == "accepted"
        assert InvitationStatus.DECLINED == "declined"
        assert InvitationStatus.WITHDRAWN == "withdrawn"


@pytest.mark.django_db
class TestGig:
    def test_create(self):
        gig = GigFactory()
        assert gig.pk is not None
        assert isinstance(gig.pk, uuid.UUID)
        assert gig.title.startswith("Showing #")
        assert gig.posted_by is not None

    def test_str(self):
        gig = GigFactory(title="Show apartment on 5th Ave")
        assert str(gig) == "Show apartment on 5th Ave"

    def test_has_timestamps(self):
        gig = GigFactory()
        assert gig.created is not None
        assert gig.modified is not None

    def test_has_soft_delete(self):
        gig = GigFactory()
        assert gig.is_deleted is False

    def test_default_status(self):
        gig = GigFactory()
        assert gig.status == GigStatus.DRAFT

    def test_default_gig_type(self):
        gig = GigFactory()
        assert gig.gig_type == GigType.SHOWING

    def test_status_transitions(self):
        """Verify we can set each status value."""
        gig = GigFactory()
        for status_value in GigStatus.values:
            gig.status = status_value
            gig.save()
            gig.refresh_from_db()
            assert gig.status == status_value

    def test_gig_type_choices(self):
        """Verify we can set each gig_type value."""
        for gig_type_value in GigType.values:
            gig = GigFactory(gig_type=gig_type_value)
            gig.refresh_from_db()
            assert gig.gig_type == gig_type_value

    def test_posted_by_relationship(self):
        profile = ProfessionalProfileFactory(license_status="verified")
        gig = GigFactory(posted_by=profile)
        assert gig.posted_by == profile
        assert gig in profile.posted_gigs.all()

    def test_assigned_to_relationship(self):
        poster = ProfessionalProfileFactory(license_status="verified")
        assignee = ProfessionalProfileFactory(license_status="verified")
        gig = GigFactory(posted_by=poster, assigned_to=assignee)
        assert gig.assigned_to == assignee
        assert gig in assignee.assigned_gigs.all()

    def test_assigned_to_nullable(self):
        gig = GigFactory(assigned_to=None)
        assert gig.assigned_to is None

    def test_service_area_relationship(self):
        gig = GigFactory()
        assert gig.service_area is not None
        assert gig in gig.service_area.gigs.all()

    def test_service_area_nullable(self):
        gig = GigFactory(service_area=None)
        assert gig.service_area is None

    def test_location_fields(self):
        gig = GigFactory(
            location_address="123 Main St",
            location_lat=Decimal("44.9778"),
            location_lng=Decimal("-93.2650"),
        )
        gig.refresh_from_db()
        assert gig.location_address == "123 Main St"
        assert gig.location_lat == Decimal("44.9778")
        assert gig.location_lng == Decimal("-93.2650")

    def test_location_lat_lng_nullable(self):
        gig = GigFactory(location_lat=None, location_lng=None)
        assert gig.location_lat is None
        assert gig.location_lng is None

    def test_budget_fields(self):
        gig = GigFactory(
            budget_range_min=Decimal("50.00"),
            budget_range_max=Decimal("150.00"),
        )
        gig.refresh_from_db()
        assert gig.budget_range_min == Decimal("50.00")
        assert gig.budget_range_max == Decimal("150.00")

    def test_budget_fields_nullable(self):
        gig = GigFactory(budget_range_min=None, budget_range_max=None)
        assert gig.budget_range_min is None
        assert gig.budget_range_max is None

    def test_agreed_price(self):
        gig = GigFactory(agreed_price=Decimal("100.00"))
        gig.refresh_from_db()
        assert gig.agreed_price == Decimal("100.00")

    def test_agreed_price_nullable(self):
        gig = GigFactory()
        assert gig.agreed_price is None

    def test_scheduling_fields(self):
        target_date = date.today() + timedelta(days=5)
        target_time = time(10, 30)
        gig = GigFactory(scheduled_date=target_date, scheduled_time=target_time)
        gig.refresh_from_db()
        assert gig.scheduled_date == target_date
        assert gig.scheduled_time == target_time

    def test_description_blank(self):
        gig = GigFactory(description="")
        assert gig.description == ""

    def test_ordering(self):
        gig1 = GigFactory()
        gig2 = GigFactory()
        gigs = list(Gig.objects.all())
        # Most recent first
        assert gigs[0] == gig2
        assert gigs[1] == gig1

    def test_posted_by_cascade_delete(self):
        gig = GigFactory()
        posted_by = gig.posted_by
        posted_by.delete()
        assert not Gig.objects.filter(pk=gig.pk).exists()


@pytest.mark.django_db
class TestGigInvitation:
    def test_create(self):
        invitation = GigInvitationFactory()
        assert invitation.pk is not None
        assert isinstance(invitation.pk, uuid.UUID)
        assert invitation.gig is not None
        assert invitation.invited_agent is not None

    def test_str(self):
        invitation = GigInvitationFactory()
        expected = f"Invitation for {invitation.gig.title} to {invitation.invited_agent}"
        assert str(invitation) == expected

    def test_has_timestamps(self):
        invitation = GigInvitationFactory()
        assert invitation.created is not None
        assert invitation.modified is not None

    def test_default_status(self):
        invitation = GigInvitationFactory()
        assert invitation.status == InvitationStatus.PENDING

    def test_status_choices(self):
        invitation = GigInvitationFactory()
        for status_value in InvitationStatus.values:
            invitation.status = status_value
            invitation.save()
            invitation.refresh_from_db()
            assert invitation.status == status_value

    def test_proposed_rate(self):
        invitation = GigInvitationFactory(proposed_rate=Decimal("100.00"))
        invitation.refresh_from_db()
        assert invitation.proposed_rate == Decimal("100.00")

    def test_proposed_rate_nullable(self):
        invitation = GigInvitationFactory(proposed_rate=None)
        assert invitation.proposed_rate is None

    def test_message_blank(self):
        invitation = GigInvitationFactory(message="")
        assert invitation.message == ""

    def test_gig_relationship(self):
        invitation = GigInvitationFactory()
        assert invitation in invitation.gig.invitations.all()

    def test_invited_agent_relationship(self):
        invitation = GigInvitationFactory()
        assert invitation in invitation.invited_agent.gig_invitations.all()

    def test_unique_together_constraint(self):
        """Can't invite the same agent to the same gig twice."""
        invitation = GigInvitationFactory()
        with pytest.raises(IntegrityError):
            GigInvitationFactory(
                gig=invitation.gig,
                invited_agent=invitation.invited_agent,
            )

    def test_gig_cascade_delete(self):
        invitation = GigInvitationFactory()
        gig = invitation.gig
        gig.delete()
        assert not GigInvitation.objects.filter(pk=invitation.pk).exists()

    def test_ordering(self):
        inv1 = GigInvitationFactory()
        inv2 = GigInvitationFactory()
        invitations = list(GigInvitation.objects.all())
        assert invitations[0] == inv2
        assert invitations[1] == inv1
