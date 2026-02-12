"""Tests for user profile update API endpoints."""

from io import BytesIO

import pytest
from django.urls import reverse
from PIL import Image
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import User
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestUserProfileUpdate:
    """Test suite for user profile update with avatar upload."""

    @pytest.fixture
    def api_client(self) -> APIClient:
        """Create an API client for testing."""
        return APIClient()

    @pytest.fixture
    def authenticated_user(self) -> User:
        """Create and return an authenticated user."""
        return UserFactory()

    def test_update_profile_with_avatar_successful(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test user can update profile with avatar upload."""
        # Create a test image
        image = Image.new("RGB", (100, 100), color="red")
        image_file = BytesIO()
        image.save(image_file, format="PNG")
        image_file.seek(0)
        image_file.name = "avatar.png"

        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-me")

        update_data = {
            "first_name": "Updated",
            "last_name": "Name",
            "avatar": image_file,
        }

        response = api_client.patch(url, update_data, format="multipart")

        assert response.status_code == status.HTTP_200_OK
        assert response.data["first_name"] == "Updated"
        assert response.data["last_name"] == "Name"
        assert "avatar" in response.data
        assert response.data["avatar"] is not None

        # Verify database was updated
        authenticated_user.refresh_from_db()
        assert authenticated_user.first_name == "Updated"
        assert authenticated_user.last_name == "Name"
        assert authenticated_user.avatar is not None
        assert authenticated_user.avatar.name

    def test_update_profile_without_avatar_successful(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test user can update profile without changing avatar."""
        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-me")

        update_data = {
            "first_name": "NoAvatar",
            "last_name": "Update",
        }

        response = api_client.patch(url, update_data, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert response.data["first_name"] == "NoAvatar"
        assert response.data["last_name"] == "Update"

        # Verify database was updated
        authenticated_user.refresh_from_db()
        assert authenticated_user.first_name == "NoAvatar"
        assert authenticated_user.last_name == "Update"

    def test_update_profile_with_invalid_image_type_fails(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test updating profile with non-image file fails."""
        # Create a text file pretending to be an image
        text_file = BytesIO(b"This is not an image")
        text_file.name = "fake.txt"

        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-me")

        update_data = {
            "avatar": text_file,
        }

        response = api_client.patch(url, update_data, format="multipart")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "avatar" in response.data

    def test_update_profile_with_large_image_fails(
        self,
        api_client: APIClient,
        authenticated_user: User,
    ) -> None:
        """Test updating profile with oversized image fails."""
        # Create a file that's exactly 6MB (exceeds 5MB limit)
        large_file_content = b"x" * (6 * 1024 * 1024)  # 6MB of data
        large_file = BytesIO(large_file_content)
        large_file.name = "large_avatar.jpg"

        api_client.force_authenticate(user=authenticated_user)
        url = reverse("api:user-me")

        update_data = {
            "avatar": large_file,
        }

        response = api_client.patch(url, update_data, format="multipart")

        # Should fail with 400 BAD REQUEST (file size validation)
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "avatar" in response.data

    def test_profile_update_requires_authentication(
        self,
        api_client: APIClient,
    ) -> None:
        """Test profile update requires authentication."""
        url = reverse("api:user-me")
        update_data = {
            "first_name": "Hacker",
        }

        response = api_client.patch(url, update_data, format="json")

        assert response.status_code == status.HTTP_401_UNAUTHORIZED
