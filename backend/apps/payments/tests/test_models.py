from decimal import Decimal

import pytest

from apps.payments.models import Payment
from apps.payments.models import PaymentStatus
from apps.payments.tests.factories import PaymentFactory

pytestmark = pytest.mark.django_db


class TestPaymentModel:
    def test_create_payment(self):
        payment = PaymentFactory()
        assert Payment.objects.count() == 1
        assert payment.amount == Decimal("100.00")
        assert payment.platform_fee == Decimal("10.00")
        assert payment.status == PaymentStatus.PENDING
        assert payment.stripe_payment_intent_id.startswith("pi_test_")
        assert payment.gig is not None

    def test_str_representation(self):
        payment = PaymentFactory(amount=Decimal("150.00"))
        expected = f"Payment for {payment.gig.title} - $150.00 (pending)"
        assert str(payment) == expected

    def test_payment_status_choices(self):
        assert PaymentStatus.PENDING == "pending"
        assert PaymentStatus.CAPTURED == "captured"
        assert PaymentStatus.RELEASED == "released"
        assert PaymentStatus.REFUNDED == "refunded"
        assert PaymentStatus.FAILED == "failed"

    def test_one_to_one_gig_relationship(self):
        payment = PaymentFactory()
        assert payment.gig.payment == payment
