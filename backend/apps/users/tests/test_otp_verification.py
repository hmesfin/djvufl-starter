"""Tests for OTP verification API endpoints."""

from datetime import timedelta

import pytest
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.users.models import EmailVerificationOTP
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


class TestOTPVerification:
    """Test suite for OTP email verification."""

    @pytest.fixture
    def api_client(self) -> APIClient:
        """Create an API client for testing."""
        return APIClient()

    def test_verify_otp_successful(self, api_client: APIClient) -> None:
        """Test successful OTP verification marks user as verified."""
        # Create user with OTP
        user = UserFactory(is_email_verified=False)
        otp = EmailVerificationOTP.create_for_user(user)

        url = reverse("api:auth-verify-otp")
        verification_data = {
            "email": user.email,
            "code": otp.code,
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_200_OK
        assert "message" in response.data

        # Verify user is now email verified
        user.refresh_from_db()
        assert user.is_email_verified is True

        # Verify OTP is marked as used
        otp.refresh_from_db()
        assert otp.is_used is True

    def test_verify_otp_with_invalid_code_fails(self, api_client: APIClient) -> None:
        """Test OTP verification with invalid code returns 400."""
        user = UserFactory(is_email_verified=False)
        _otp = EmailVerificationOTP.create_for_user(user)

        url = reverse("api:auth-verify-otp")
        verification_data = {
            "email": user.email,
            "code": "999999",  # Wrong code
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST

        # User should still not be verified
        user.refresh_from_db()
        assert user.is_email_verified is False

    def test_verify_otp_with_expired_code_fails(self, api_client: APIClient) -> None:
        """Test OTP verification with expired code returns 400."""
        user = UserFactory(is_email_verified=False)
        otp = EmailVerificationOTP.create_for_user(user)

        # Manually expire the OTP
        otp.expires_at = timezone.now() - timedelta(minutes=1)
        otp.save()

        url = reverse("api:auth-verify-otp")
        verification_data = {
            "email": user.email,
            "code": otp.code,
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST

        # User should still not be verified
        user.refresh_from_db()
        assert user.is_email_verified is False

    def test_verify_otp_with_used_code_fails(self, api_client: APIClient) -> None:
        """Test OTP verification with already used code returns 400."""
        user = UserFactory(is_email_verified=False)
        otp = EmailVerificationOTP.create_for_user(user)
        otp.mark_as_used()

        url = reverse("api:auth-verify-otp")
        verification_data = {
            "email": user.email,
            "code": otp.code,
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_verify_otp_with_nonexistent_email_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test OTP verification with non-existent email returns 400."""
        url = reverse("api:auth-verify-otp")
        verification_data = {
            "email": "nonexistent@example.com",
            "code": "123456",
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_verify_otp_without_required_fields_fails(
        self,
        api_client: APIClient,
    ) -> None:
        """Test OTP verification without required fields returns 400."""
        url = reverse("api:auth-verify-otp")

        # Missing code
        response = api_client.post(
            url,
            {"email": "test@example.com"},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

        # Missing email
        response = api_client.post(
            url,
            {"code": "123456"},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_verify_otp_uses_most_recent_valid_code(
        self,
        api_client: APIClient,
    ) -> None:
        """Test OTP verification uses the most recent valid code."""
        user = UserFactory(is_email_verified=False)

        # Create two OTPs
        _old_otp = EmailVerificationOTP.create_for_user(user)
        new_otp = EmailVerificationOTP.create_for_user(user)

        url = reverse("api:auth-verify-otp")

        # Verify with new code should work
        verification_data = {
            "email": user.email,
            "code": new_otp.code,
        }

        response = api_client.post(url, verification_data, format="json")

        assert response.status_code == status.HTTP_200_OK

        # User should be verified
        user.refresh_from_db()
        assert user.is_email_verified is True
