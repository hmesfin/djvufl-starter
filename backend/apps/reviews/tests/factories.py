import factory

from apps.gigs.tests.factories import GigFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.reviews.models import Review


class ReviewFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Review

    gig = factory.SubFactory(GigFactory, status="completed")
    reviewer = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    reviewee = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    rating = 5
    comment = factory.Faker("sentence")
    is_from_poster = True
