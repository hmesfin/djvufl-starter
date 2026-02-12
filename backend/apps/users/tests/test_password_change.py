"""Tests for password change API endpoints."""

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import User
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestPasswordChange:
    """Test suite for password change endpoint."""

    @pytest.fixture
    def api_client(self) -> APIClient:
        """Create an API client for testing."""
        return APIClient()

    @pytest.fixture
    def authenticated_user(self) -> User:
        """Create and return an authenticated user with known password."""
        user = UserFactory()
        user.set_password("OldPassword123!")
        user.save()
        return user

    def test_change_password_successful(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test user can change password with correct old password."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-change-password")

        password_data = {
            "old_password": "OldPassword123!",
            "new_password": "NewSecurePass456!",
        }

        response = api_client.post(url, password_data, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert "message" in response.data

        # Verify password was changed
        authenticated_user.refresh_from_db()
        assert authenticated_user.check_password("NewSecurePass456!")
        assert not authenticated_user.check_password("OldPassword123!")

    def test_change_password_with_incorrect_old_password_fails(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test password change fails with incorrect old password."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-change-password")

        password_data = {
            "old_password": "WrongPassword123!",
            "new_password": "NewSecurePass456!",
        }

        response = api_client.post(url, password_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "old_password" in response.data

        # Verify password was NOT changed
        authenticated_user.refresh_from_db()
        assert authenticated_user.check_password("OldPassword123!")

    def test_change_password_with_weak_new_password_fails(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test password change fails with weak new password."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-change-password")

        password_data = {
            "old_password": "OldPassword123!",
            "new_password": "123",  # Too short
        }

        response = api_client.post(url, password_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "new_password" in response.data

        # Verify password was NOT changed
        authenticated_user.refresh_from_db()
        assert authenticated_user.check_password("OldPassword123!")

    def test_change_password_with_same_password_allowed(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test user can set password to same value (no uniqueness requirement)."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-change-password")

        password_data = {
            "old_password": "OldPassword123!",
            "new_password": "OldPassword123!",
        }

        response = api_client.post(url, password_data, format="json")

        # Should succeed (no requirement for different password)
        assert response.status_code == status.HTTP_200_OK

    def test_change_password_requires_authentication(
        self,
        api_client: APIClient,
    ) -> None:
        """Test password change requires authentication."""
        url = reverse("api:user-change-password")
        password_data = {
            "old_password": "OldPassword123!",
            "new_password": "NewSecurePass456!",
        }

        response = api_client.post(url, password_data, format="json")

        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_change_password_without_required_fields_fails(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test password change without required fields returns 400."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-change-password")

        # Missing new_password
        response = api_client.post(
            url,
            {"old_password": "OldPassword123!"},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "new_password" in response.data

        # Missing old_password
        response = api_client.post(
            url,
            {"new_password": "NewSecurePass456!"},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "old_password" in response.data
