import factory

from apps.messaging.models import Conversation, Message
from apps.professionals.tests.factories import ProfessionalProfileFactory


class ConversationFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Conversation

    participant_1 = factory.SubFactory(
        ProfessionalProfileFactory, license_status="verified"
    )
    participant_2 = factory.SubFactory(
        ProfessionalProfileFactory, license_status="verified"
    )


class MessageFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Message

    conversation = factory.SubFactory(ConversationFactory)
    sender = factory.LazyAttribute(lambda obj: obj.conversation.participant_1)
    body = factory.Faker("sentence")
