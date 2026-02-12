"""Tests for JWT authentication API endpoints."""

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestJWTAuthentication:
    """Test suite for JWT token authentication with email verification."""

    @pytest.fixture
    def api_client(self) -> APIClient:
        """Create an API client for testing."""
        return APIClient()

    def test_obtain_token_with_verified_email_successful(
        self,
        api_client: APIClient,
    ) -> None:
        """Test obtaining JWT tokens with verified email is successful."""
        # Create user with verified email
        user = UserFactory(is_email_verified=True)
        password = "SecurePass123!"
        user.set_password(password)
        user.save()

        url = reverse("api:auth-token")
        credentials = {
            "email": user.email,
            "password": password,
        }

        response = api_client.post(url, credentials, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data
        assert "refresh" in response.data
        assert response.data["access"] is not None
        assert response.data["refresh"] is not None

    def test_obtain_token_with_unverified_email_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test obtaining JWT tokens with unverified email fails."""
        # Create user with unverified email
        user = UserFactory(is_email_verified=False)
        password = "SecurePass123!"
        user.set_password(password)
        user.save()

        url = reverse("api:auth-token")
        credentials = {
            "email": user.email,
            "password": password,
        }

        response = api_client.post(url, credentials, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "email" in response.data or "detail" in response.data

    def test_obtain_token_with_invalid_credentials_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test obtaining JWT tokens with invalid credentials fails."""
        user = UserFactory(is_email_verified=True)

        url = reverse("api:auth-token")
        credentials = {
            "email": user.email,
            "password": "WrongPassword123!",
        }

        response = api_client.post(url, credentials, format="json")

        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_refresh_token_successful(self, api_client: APIClient) -> None:
        """Test refreshing JWT tokens is successful."""
        # Create user and obtain tokens first
        user = UserFactory(is_email_verified=True)
        password = "SecurePass123!"
        user.set_password(password)
        user.save()

        # Obtain initial tokens
        token_url = reverse("api:auth-token")
        credentials = {
            "email": user.email,
            "password": password,
        }
        token_response = api_client.post(token_url, credentials, format="json")
        refresh_token = token_response.data["refresh"]

        # Refresh the token
        refresh_url = reverse("api:auth-token-refresh")
        refresh_data = {"refresh": refresh_token}

        response = api_client.post(refresh_url, refresh_data, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert "access" in response.data
        assert response.data["access"] is not None

    def test_access_protected_endpoint_with_valid_token(
        self,
        api_client: APIClient,
    ) -> None:
        """Test accessing protected endpoint with valid JWT token."""
        # Create user and obtain token
        user = UserFactory(is_email_verified=True)
        password = "SecurePass123!"
        user.set_password(password)
        user.save()

        # Obtain token
        token_url = reverse("api:auth-token")
        credentials = {
            "email": user.email,
            "password": password,
        }
        token_response = api_client.post(token_url, credentials, format="json")
        access_token = token_response.data["access"]

        # Access protected endpoint
        api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")
        url = reverse("api:user-me")
        response = api_client.get(url)

        assert response.status_code == status.HTTP_200_OK
        assert response.data["email"] == user.email

    def test_access_protected_endpoint_without_token_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test accessing protected endpoint without token fails."""
        url = reverse("api:user-me")
        response = api_client.get(url)

        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_access_protected_endpoint_with_invalid_token_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test accessing protected endpoint with invalid token fails."""
        # Use invalid token
        api_client.credentials(HTTP_AUTHORIZATION="Bearer invalid_token_here")
        url = reverse("api:user-me")
        response = api_client.get(url)

        assert response.status_code == status.HTTP_401_UNAUTHORIZED
