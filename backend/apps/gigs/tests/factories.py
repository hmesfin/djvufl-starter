from datetime import date, time, timedelta
from decimal import Decimal

import factory

from apps.gigs.models import Gig, GigInvitation
from apps.professionals.tests.factories import (
    ProfessionalProfileFactory,
    ServiceAreaFactory,
)


class GigFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Gig

    posted_by = factory.SubFactory(
        ProfessionalProfileFactory, license_status="verified"
    )
    title = factory.Sequence(lambda n: f"Showing #{n}")
    description = factory.Faker("paragraph")
    location_address = factory.Faker("address")
    location_lat = factory.LazyFunction(lambda: Decimal("44.9778"))
    location_lng = factory.LazyFunction(lambda: Decimal("-93.2650"))
    service_area = factory.SubFactory(ServiceAreaFactory)
    scheduled_date = factory.LazyFunction(lambda: date.today() + timedelta(days=3))
    scheduled_time = factory.LazyFunction(lambda: time(14, 0))
    budget_range_min = factory.LazyFunction(lambda: Decimal("50.00"))
    budget_range_max = factory.LazyFunction(lambda: Decimal("150.00"))
    gig_type = "showing"


class GigInvitationFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = GigInvitation

    gig = factory.SubFactory(GigFactory, status="posted")
    invited_agent = factory.SubFactory(
        ProfessionalProfileFactory, license_status="verified"
    )
    proposed_rate = factory.LazyFunction(lambda: Decimal("75.00"))
    message = factory.Faker("sentence")
