import datetime
from datetime import timedelta
from decimal import Decimal

import pytest
from django.db import IntegrityError

from apps.professionals.models import (
    LicenseStatus,
    Metro,
    ProfessionalProfile,
    ServiceArea,
    Specialization,
)
from apps.professionals.tests.factories import (
    MetroFactory,
    ProfessionalProfileFactory,
    ServiceAreaFactory,
)
from apps.users.tests.factories import UserFactory


@pytest.mark.django_db
class TestMetro:
    def test_create(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        assert metro.pk is not None
        assert metro.name == "Minneapolis-St. Paul"
        assert metro.state == "MN"

    def test_str(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        assert str(metro) == "Minneapolis-St. Paul, MN"

    def test_unique_together(self):
        MetroFactory(name="Minneapolis-St. Paul", state="MN")
        with pytest.raises(IntegrityError):
            MetroFactory(name="Minneapolis-St. Paul", state="MN")

    def test_has_timestamps(self):
        metro = MetroFactory()
        assert metro.created is not None
        assert metro.modified is not None

    def test_has_uuid_pk(self):
        metro = MetroFactory()
        import uuid

        assert isinstance(metro.pk, uuid.UUID)


@pytest.mark.django_db
class TestServiceArea:
    def test_create(self):
        area = ServiceAreaFactory(name="Downtown Minneapolis")
        assert area.pk is not None
        assert area.name == "Downtown Minneapolis"
        assert area.zip_codes == ["55401", "55402"]

    def test_str(self):
        area = ServiceAreaFactory(name="Downtown Minneapolis")
        assert str(area) == "Downtown Minneapolis"

    def test_metro_relationship(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        area = ServiceAreaFactory(name="Downtown", metro=metro)
        assert area.metro == metro
        assert area in metro.service_areas.all()

    def test_unique_together(self):
        metro = MetroFactory()
        ServiceAreaFactory(name="Downtown", metro=metro)
        with pytest.raises(IntegrityError):
            ServiceAreaFactory(name="Downtown", metro=metro)


@pytest.mark.django_db
class TestProfessionalProfile:
    def test_create(self):
        profile = ProfessionalProfileFactory()
        assert profile.pk is not None
        assert profile.user is not None
        assert profile.license_number.startswith("MN-RE-")

    def test_str(self):
        user = UserFactory(first_name="Jane", last_name="Doe")
        profile = ProfessionalProfileFactory(user=user)
        assert str(profile) == "Jane Doe"

    def test_user_one_to_one(self):
        user = UserFactory()
        ProfessionalProfileFactory(user=user)
        with pytest.raises(IntegrityError):
            ProfessionalProfileFactory(user=user)

    def test_license_status_choices(self):
        assert LicenseStatus.PENDING == "pending_verification"
        assert LicenseStatus.VERIFIED == "verified"
        assert LicenseStatus.REJECTED == "rejected"
        assert LicenseStatus.EXPIRED == "expired"

    def test_default_license_status(self):
        profile = ProfessionalProfileFactory()
        assert profile.license_status == LicenseStatus.PENDING

    def test_specialization_choices(self):
        assert Specialization.RESIDENTIAL == "residential"
        assert Specialization.COMMERCIAL == "commercial"
        assert Specialization.BUYERS_AGENT == "buyers_agent"
        assert Specialization.LISTING_AGENT == "listing_agent"

    def test_specializations_field(self):
        profile = ProfessionalProfileFactory()
        profile.specializations = [
            Specialization.RESIDENTIAL,
            Specialization.BUYERS_AGENT,
        ]
        profile.save()
        profile.refresh_from_db()
        assert profile.specializations == ["residential", "buyers_agent"]

    def test_service_areas_m2m(self):
        area1 = ServiceAreaFactory()
        area2 = ServiceAreaFactory()
        profile = ProfessionalProfileFactory(service_areas=[area1, area2])
        assert area1 in profile.service_areas.all()
        assert area2 in profile.service_areas.all()
        assert profile in area1.professionals.all()

    def test_is_verified_property(self):
        profile = ProfessionalProfileFactory(license_status=LicenseStatus.PENDING)
        assert profile.is_verified is False

        profile.license_status = LicenseStatus.VERIFIED
        assert profile.is_verified is True

    def test_is_available_default(self):
        profile = ProfessionalProfileFactory()
        assert profile.is_available is True

    def test_optional_fields_default(self):
        profile = ProfessionalProfileFactory()
        assert profile.license_expiry is None
        assert profile.average_rating is None
        assert profile.average_response_time is None
        assert profile.verified_at is None
        assert profile.verified_by is None
        assert profile.last_reverification_check is None
        assert profile.stripe_connect_account_id == ""
        assert profile.rejection_reason == ""

    def test_verified_by_relationship(self):
        admin_user = UserFactory()
        profile = ProfessionalProfileFactory(verified_by=admin_user)
        assert profile.verified_by == admin_user
        assert profile in admin_user.verifications_performed.all()

    def test_user_reverse_relation(self):
        profile = ProfessionalProfileFactory()
        assert profile.user.professional_profile == profile

    def test_unique_license_number(self):
        ProfessionalProfileFactory(license_number="MN-RE-000001")
        with pytest.raises(IntegrityError):
            ProfessionalProfileFactory(license_number="MN-RE-000001")

    def test_average_rating_decimal(self):
        profile = ProfessionalProfileFactory()
        profile.average_rating = Decimal("4.75")
        profile.save()
        profile.refresh_from_db()
        assert profile.average_rating == Decimal("4.75")

    def test_average_response_time(self):
        profile = ProfessionalProfileFactory()
        profile.average_response_time = timedelta(hours=2, minutes=30)
        profile.save()
        profile.refresh_from_db()
        assert profile.average_response_time == timedelta(hours=2, minutes=30)
