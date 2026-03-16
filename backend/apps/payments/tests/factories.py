from decimal import Decimal

import factory

from apps.gigs.tests.factories import GigFactory
from apps.payments.models import Payment


class PaymentFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Payment

    gig = factory.SubFactory(GigFactory, status="accepted", agreed_price=Decimal("100.00"))
    stripe_payment_intent_id = factory.Sequence(lambda n: f"pi_test_{n:06d}")
    amount = factory.LazyFunction(lambda: Decimal("100.00"))
    platform_fee = factory.LazyFunction(lambda: Decimal("10.00"))
    status = "pending"
