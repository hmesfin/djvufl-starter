"""Tests for user registration API endpoints."""

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import EmailVerificationOTP
from apps.users.models import User
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestUserRegistration:
    """Test suite for user registration with OTP email verification."""

    @pytest.fixture
    def api_client(self) -> APIClient:
        """Create an API client for testing."""
        return APIClient()

    def test_register_user_successful(self, api_client: APIClient) -> None:
        """Test successful user registration creates user and OTP."""
        url = reverse("api:auth-register")
        registration_data = {
            "email": "newuser@example.com",
            "password": "SecurePass123!",
            "first_name": "John",
            "last_name": "Doe",
        }

        response = api_client.post(url, registration_data, format="json")

        assert response.status_code == status.HTTP_201_CREATED
        assert "email" in response.data
        assert response.data["email"] == "newuser@example.com"
        assert "password" not in response.data  # Password should not be in response

        # Verify user was created
        user = User.objects.get(email="newuser@example.com")
        assert user.first_name == "John"
        assert user.last_name == "Doe"
        assert user.is_email_verified is False  # Should not be verified yet
        assert user.is_active is True  # Should be active
        assert user.check_password("SecurePass123!")  # Password should be hashed

        # Verify OTP was created
        otp_code_length = 6
        otp = EmailVerificationOTP.objects.filter(user=user, is_used=False).first()
        assert otp is not None
        assert len(otp.code) == otp_code_length
        assert otp.is_valid() is True

    def test_register_user_with_duplicate_email_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test registration with duplicate email returns 400."""
        _existing_user = UserFactory(email="existing@example.com")

        url = reverse("api:auth-register")
        registration_data = {
            "email": "existing@example.com",
            "password": "SecurePass123!",
            "first_name": "John",
            "last_name": "Doe",
        }

        response = api_client.post(url, registration_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "email" in response.data

    def test_register_user_with_invalid_email_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test registration with invalid email returns 400."""
        url = reverse("api:auth-register")
        registration_data = {
            "email": "not-an-email",
            "password": "SecurePass123!",
            "first_name": "John",
            "last_name": "Doe",
        }

        response = api_client.post(url, registration_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "email" in response.data

    def test_register_user_without_required_fields_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test registration without required fields returns 400."""
        url = reverse("api:auth-register")

        # Missing first_name
        response = api_client.post(
            url,
            {
                "email": "test@example.com",
                "password": "SecurePass123!",
                "last_name": "Doe",
            },
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "first_name" in response.data

        # Missing last_name
        response = api_client.post(
            url,
            {
                "email": "test@example.com",
                "password": "SecurePass123!",
                "first_name": "John",
            },
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "last_name" in response.data

        # Missing password
        response = api_client.post(
            url,
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "Doe",
            },
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "password" in response.data

    def test_register_user_with_weak_password_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test registration with weak password returns 400."""
        url = reverse("api:auth-register")
        registration_data = {
            "email": "test@example.com",
            "password": "123",  # Too short
            "first_name": "John",
            "last_name": "Doe",
        }

        response = api_client.post(url, registration_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "password" in response.data

    def test_registration_normalizes_email(self, api_client: APIClient) -> None:
        """Test registration normalizes email to lowercase."""
        url = reverse("api:auth-register")
        registration_data = {
            "email": "NewUser@EXAMPLE.COM",
            "password": "SecurePass123!",
            "first_name": "John",
            "last_name": "Doe",
        }

        response = api_client.post(url, registration_data, format="json")

        assert response.status_code == status.HTTP_201_CREATED
        user = User.objects.get(email="newuser@example.com")
        assert user.email == "newuser@example.com"
