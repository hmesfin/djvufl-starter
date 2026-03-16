"""Tests for professionals app serializers."""

import pytest
from rest_framework.test import APIRequestFactory

from apps.professionals.api.serializers import (
    MetroSerializer,
    MyProfessionalProfileSerializer,
    ProfessionalProfileCreateSerializer,
    ProfessionalProfileSerializer,
    ServiceAreaSerializer,
)
from apps.professionals.models import LicenseStatus
from apps.professionals.tests.factories import (
    MetroFactory,
    ProfessionalProfileFactory,
    ServiceAreaFactory,
)
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestMetroSerializer:
    def test_serializes_correctly(self) -> None:
        metro = MetroFactory(name="Minneapolis", state="MN")
        serializer = MetroSerializer(metro)
        data = serializer.data

        assert data["uuid"] == str(metro.id)
        assert data["name"] == "Minneapolis"
        assert data["state"] == "MN"
        assert set(data.keys()) == {"uuid", "name", "state"}

    def test_uuid_is_read_only(self) -> None:
        serializer = MetroSerializer()
        assert serializer.fields["uuid"].read_only is True


class TestServiceAreaSerializer:
    def test_serializes_with_nested_metro(self) -> None:
        metro = MetroFactory(name="St. Paul", state="MN")
        area = ServiceAreaFactory(
            name="Downtown", metro=metro, zip_codes=["55101", "55102"]
        )
        serializer = ServiceAreaSerializer(area)
        data = serializer.data

        assert data["uuid"] == str(area.id)
        assert data["name"] == "Downtown"
        assert data["zip_codes"] == ["55101", "55102"]
        assert data["metro"]["name"] == "St. Paul"
        assert data["metro"]["state"] == "MN"


class TestProfessionalProfileSerializer:
    def test_includes_expected_fields(self) -> None:
        area = ServiceAreaFactory()
        profile = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            service_areas=[area],
            specializations=["residential"],
            bio="Experienced agent",
        )
        serializer = ProfessionalProfileSerializer(profile)
        data = serializer.data

        expected_fields = {
            "uuid",
            "user_email",
            "user_first_name",
            "user_last_name",
            "user_avatar",
            "license_status",
            "service_areas",
            "specializations",
            "bio",
            "average_rating",
            "average_response_time",
            "is_available",
            "is_verified",
        }
        assert set(data.keys()) == expected_fields

    def test_excludes_sensitive_fields(self) -> None:
        profile = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            license_number="MN-RE-999999",
            stripe_connect_account_id="acct_abc123",
        )
        serializer = ProfessionalProfileSerializer(profile)
        data = serializer.data

        assert "license_number" not in data
        assert "stripe_connect_account_id" not in data

    def test_user_fields_populated(self) -> None:
        user = UserFactory(
            first_name="Jane", last_name="Doe", email="jane@example.com"
        )
        profile = ProfessionalProfileFactory(user=user)
        serializer = ProfessionalProfileSerializer(profile)
        data = serializer.data

        assert data["user_email"] == "jane@example.com"
        assert data["user_first_name"] == "Jane"
        assert data["user_last_name"] == "Doe"

    def test_service_areas_nested(self) -> None:
        area = ServiceAreaFactory()
        profile = ProfessionalProfileFactory(service_areas=[area])
        serializer = ProfessionalProfileSerializer(profile)
        data = serializer.data

        assert len(data["service_areas"]) == 1
        assert data["service_areas"][0]["name"] == area.name


class TestProfessionalProfileCreateSerializer:
    def test_creates_profile_from_request_context(self) -> None:
        user = UserFactory()
        area = ServiceAreaFactory()
        factory = APIRequestFactory()
        request = factory.post("/fake-url/")
        request.user = user

        payload = {
            "license_number": "MN-RE-123456",
            "bio": "Test bio",
            "specializations": ["residential", "commercial"],
            "is_available": True,
            "service_area_uuids": [str(area.id)],
        }
        serializer = ProfessionalProfileCreateSerializer(
            data=payload, context={"request": request}
        )
        assert serializer.is_valid(), serializer.errors
        profile = serializer.save()

        assert profile.user == user
        assert profile.license_number == "MN-RE-123456"
        assert profile.bio == "Test bio"
        assert list(profile.service_areas.all()) == [area]

    def test_update_profile(self) -> None:
        profile = ProfessionalProfileFactory(bio="Old bio")
        new_area = ServiceAreaFactory()
        factory = APIRequestFactory()
        request = factory.patch("/fake-url/")
        request.user = profile.user

        payload = {
            "bio": "New bio",
            "service_area_uuids": [str(new_area.id)],
        }
        serializer = ProfessionalProfileCreateSerializer(
            profile, data=payload, partial=True, context={"request": request}
        )
        assert serializer.is_valid(), serializer.errors
        updated = serializer.save()

        assert updated.bio == "New bio"
        assert list(updated.service_areas.all()) == [new_area]


class TestMyProfessionalProfileSerializer:
    def test_includes_private_fields(self) -> None:
        profile = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            license_number="MN-RE-777777",
        )
        serializer = MyProfessionalProfileSerializer(profile)
        data = serializer.data

        assert "license_number" in data
        assert "license_expiry" in data
        assert "verified_at" in data
        assert "rejection_reason" in data
        assert data["license_number"] == "MN-RE-777777"
