from decimal import Decimal
from unittest.mock import MagicMock
from unittest.mock import patch

import pytest
from rest_framework.test import APIClient

from apps.gigs.tests.factories import GigFactory
from apps.payments.tests.factories import PaymentFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory

pytestmark = pytest.mark.django_db


class TestStripeConnectOnboardView:
    def setup_method(self):
        self.client = APIClient()
        self.profile = ProfessionalProfileFactory(license_status="verified")
        self.user = self.profile.user
        self.client.force_authenticate(user=self.user)

    @patch("apps.payments.services.stripe.AccountLink.create")
    @patch("apps.payments.services.stripe.Account.create")
    def test_stripe_connect_onboard_new_account(self, mock_account_create, mock_link_create):
        mock_account = MagicMock()
        mock_account.id = "acct_test_123"
        mock_account_create.return_value = mock_account

        mock_link = MagicMock()
        mock_link.url = "https://connect.stripe.com/setup/test"
        mock_link_create.return_value = mock_link

        response = self.client.post("/api/payments/stripe-connect/")
        assert response.status_code == 200
        assert response.data["url"] == "https://connect.stripe.com/setup/test"

        self.profile.refresh_from_db()
        assert self.profile.stripe_connect_account_id == "acct_test_123"

    @patch("apps.payments.services.stripe.AccountLink.create")
    def test_stripe_connect_onboard_existing_account(self, mock_link_create):
        self.profile.stripe_connect_account_id = "acct_existing_456"
        self.profile.save(update_fields=["stripe_connect_account_id"])

        mock_link = MagicMock()
        mock_link.url = "https://connect.stripe.com/setup/existing"
        mock_link_create.return_value = mock_link

        response = self.client.post("/api/payments/stripe-connect/")
        assert response.status_code == 200
        assert response.data["url"] == "https://connect.stripe.com/setup/existing"

    def test_stripe_connect_requires_verified_professional(self):
        unverified_profile = ProfessionalProfileFactory(license_status="pending_verification")
        self.client.force_authenticate(user=unverified_profile.user)
        response = self.client.post("/api/payments/stripe-connect/")
        assert response.status_code == 403

    def test_stripe_connect_requires_authentication(self):
        self.client.force_authenticate(user=None)
        response = self.client.post("/api/payments/stripe-connect/")
        assert response.status_code in (401, 403)


class TestPaymentDetailView:
    def setup_method(self):
        self.client = APIClient()
        self.profile = ProfessionalProfileFactory(license_status="verified")
        self.user = self.profile.user
        self.client.force_authenticate(user=self.user)

    def test_payment_detail(self):
        gig = GigFactory(posted_by=self.profile, agreed_price=Decimal("200.00"))
        payment = PaymentFactory(
            gig=gig,
            amount=Decimal("200.00"),
            platform_fee=Decimal("20.00"),
        )
        response = self.client.get(f"/api/payments/{gig.id}/")
        assert response.status_code == 200
        assert response.data["amount"] == "200.00"
        assert response.data["platform_fee"] == "20.00"
        assert response.data["status"] == "pending"
        assert response.data["gig_uuid"] == str(gig.id)

    def test_payment_detail_not_found(self):
        import uuid

        fake_uuid = uuid.uuid4()
        response = self.client.get(f"/api/payments/{fake_uuid}/")
        assert response.status_code == 404


class TestStripeWebhookView:
    def setup_method(self):
        self.client = APIClient()

    @patch("apps.payments.services.stripe.Webhook.construct_event")
    def test_webhook_payment_succeeded(self, mock_construct):
        payment = PaymentFactory(stripe_payment_intent_id="pi_webhook_test")

        mock_event = MagicMock()
        mock_event.type = "payment_intent.succeeded"
        mock_event.data.object = {"id": "pi_webhook_test"}
        mock_construct.return_value = mock_event

        response = self.client.post(
            "/api/payments/webhook/",
            data=b"raw_payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="test_sig",
        )
        assert response.status_code == 200

        payment.refresh_from_db()
        assert payment.status == "captured"

    @patch("apps.payments.services.stripe.Webhook.construct_event")
    def test_webhook_payment_failed(self, mock_construct):
        payment = PaymentFactory(stripe_payment_intent_id="pi_fail_test")

        mock_event = MagicMock()
        mock_event.type = "payment_intent.payment_failed"
        mock_event.data.object = {"id": "pi_fail_test"}
        mock_construct.return_value = mock_event

        response = self.client.post(
            "/api/payments/webhook/",
            data=b"raw_payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="test_sig",
        )
        assert response.status_code == 200

        payment.refresh_from_db()
        assert payment.status == "failed"

    @patch("apps.payments.services.stripe.Webhook.construct_event")
    def test_webhook_invalid_signature(self, mock_construct):
        mock_construct.side_effect = Exception("Invalid signature")

        response = self.client.post(
            "/api/payments/webhook/",
            data=b"raw_payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="bad_sig",
        )
        assert response.status_code == 400
