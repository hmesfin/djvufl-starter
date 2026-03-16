"""Tests for professionals app views."""

from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.professionals.models import LicenseStatus
from apps.professionals.tests.factories import (
    MetroFactory,
    ProfessionalProfileFactory,
    ServiceAreaFactory,
)
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


@pytest.fixture()
def api_client() -> APIClient:
    return APIClient()


@pytest.fixture()
def authenticated_client(api_client: APIClient) -> APIClient:
    user = UserFactory()
    api_client.force_authenticate(user=user)
    api_client.user = user  # type: ignore[attr-defined]
    return api_client


class TestProfessionalProfileListView:
    url = reverse("api:professional-list")

    def test_list_only_shows_verified_profiles(
        self, authenticated_client: APIClient
    ) -> None:
        ProfessionalProfileFactory(license_status=LicenseStatus.VERIFIED)
        ProfessionalProfileFactory(license_status=LicenseStatus.PENDING)
        ProfessionalProfileFactory(license_status=LicenseStatus.REJECTED)

        response = authenticated_client.get(self.url)

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_filter_by_service_area(self, authenticated_client: APIClient) -> None:
        area = ServiceAreaFactory()
        other_area = ServiceAreaFactory()
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED, service_areas=[area]
        )
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED, service_areas=[other_area]
        )

        response = authenticated_client.get(self.url, {"service_area": str(area.id)})

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_filter_by_is_available(self, authenticated_client: APIClient) -> None:
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED, is_available=True
        )
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED, is_available=False
        )

        response = authenticated_client.get(self.url, {"is_available": "true"})

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_filter_by_min_rating(self, authenticated_client: APIClient) -> None:
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            average_rating=Decimal("4.5"),
        )
        ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            average_rating=Decimal("3.0"),
        )

        response = authenticated_client.get(self.url, {"min_rating": "4.0"})

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_unauthenticated_cannot_list(self, api_client: APIClient) -> None:
        response = api_client.get(self.url)

        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestProfessionalProfileDetailView:
    def test_retrieve_verified_profile(self, authenticated_client: APIClient) -> None:
        profile = ProfessionalProfileFactory(
            license_status=LicenseStatus.VERIFIED,
            license_number="MN-RE-SECRET",
        )
        url = reverse("api:professional-detail", kwargs={"uuid": profile.id})

        response = authenticated_client.get(url)

        assert response.status_code == status.HTTP_200_OK
        assert "license_number" not in response.data

    def test_cannot_retrieve_unverified_profile(
        self, authenticated_client: APIClient
    ) -> None:
        profile = ProfessionalProfileFactory(
            license_status=LicenseStatus.PENDING,
        )
        url = reverse("api:professional-detail", kwargs={"uuid": profile.id})

        response = authenticated_client.get(url)

        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestMyProfessionalProfileView:
    url = reverse("api:professional-me")

    def test_get_own_profile(self, authenticated_client: APIClient) -> None:
        profile = ProfessionalProfileFactory(
            user=authenticated_client.user,  # type: ignore[attr-defined]
            license_number="MN-RE-MINE",
        )
        response = authenticated_client.get(self.url)

        assert response.status_code == status.HTTP_200_OK
        assert response.data["license_number"] == "MN-RE-MINE"
        assert response.data["uuid"] == str(profile.id)

    def test_returns_404_if_no_profile(self, authenticated_client: APIClient) -> None:
        response = authenticated_client.get(self.url)

        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_own_profile(self, authenticated_client: APIClient) -> None:
        area = ServiceAreaFactory()
        payload = {
            "license_number": "MN-RE-NEW001",
            "bio": "New professional",
            "specializations": ["residential"],
            "is_available": True,
            "service_area_uuids": [str(area.id)],
        }
        response = authenticated_client.post(self.url, payload, format="json")

        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["license_number"] == "MN-RE-NEW001"
        assert response.data["user_email"] == authenticated_client.user.email  # type: ignore[attr-defined]

    def test_update_own_profile(self, authenticated_client: APIClient) -> None:
        ProfessionalProfileFactory(
            user=authenticated_client.user,  # type: ignore[attr-defined]
            bio="Old bio",
        )
        payload = {"bio": "Updated bio"}
        response = authenticated_client.patch(self.url, payload, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert response.data["bio"] == "Updated bio"


class TestServiceAreaListView:
    url = reverse("api:servicearea-list")

    def test_list_service_areas(self, authenticated_client: APIClient) -> None:
        ServiceAreaFactory.create_batch(3)

        response = authenticated_client.get(self.url)

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 3

    def test_unauthenticated_cannot_list(self, api_client: APIClient) -> None:
        response = api_client.get(self.url)

        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestMetroListView:
    url = reverse("api:metro-list")

    def test_list_metros(self, authenticated_client: APIClient) -> None:
        MetroFactory.create_batch(2)

        response = authenticated_client.get(self.url)

        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 2

    def test_unauthenticated_cannot_list(self, api_client: APIClient) -> None:
        response = api_client.get(self.url)

        assert response.status_code == status.HTTP_401_UNAUTHORIZED
