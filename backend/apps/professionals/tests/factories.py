import factory

from apps.professionals.models import Metro, ProfessionalProfile, ServiceArea
from apps.users.tests.factories import UserFactory


class MetroFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Metro

    name = factory.Sequence(lambda n: f"Metro {n}")
    state = "MN"


class ServiceAreaFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ServiceArea

    name = factory.Sequence(lambda n: f"Area {n}")
    metro = factory.SubFactory(MetroFactory)

    @factory.lazy_attribute
    def zip_codes(self):
        return ["55401", "55402"]


class ProfessionalProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ProfessionalProfile
        skip_postgeneration_save = True

    user = factory.SubFactory(UserFactory)
    license_number = factory.Sequence(lambda n: f"MN-RE-{n:06d}")
    license_status = "pending_verification"
    bio = factory.Faker("paragraph")
    is_available = True

    @factory.post_generation
    def service_areas(self, create, extracted, **kwargs):
        if not create or not extracted:
            return
        self.service_areas.add(*extracted)
        self.save()
