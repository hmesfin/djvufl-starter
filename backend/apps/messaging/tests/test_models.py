import uuid

import pytest
from django.utils import timezone

from apps.messaging.models import Conversation, Message
from apps.messaging.tests.factories import ConversationFactory, MessageFactory


@pytest.mark.django_db
class TestConversation:
    def test_create(self):
        conversation = ConversationFactory()
        assert conversation.pk is not None
        assert isinstance(conversation.pk, uuid.UUID)
        assert conversation.participant_1 is not None
        assert conversation.participant_2 is not None

    def test_str(self):
        conversation = ConversationFactory()
        expected = f"Conversation between {conversation.participant_1} and {conversation.participant_2}"
        assert str(conversation) == expected

    def test_has_timestamps(self):
        conversation = ConversationFactory()
        assert conversation.created is not None
        assert conversation.modified is not None

    def test_has_soft_delete(self):
        conversation = ConversationFactory()
        assert conversation.is_deleted is False

    def test_gig_nullable(self):
        conversation = ConversationFactory(gig=None)
        assert conversation.gig is None

    def test_ordering(self):
        c1 = ConversationFactory()
        c2 = ConversationFactory()
        conversations = list(Conversation.objects.all())
        # Most recently modified first
        assert conversations[0] == c2
        assert conversations[1] == c1

    def test_unique_together_with_gig(self):
        """Can't have two conversations with the same participants and gig."""
        from apps.gigs.tests.factories import GigFactory

        gig = GigFactory()
        conversation = ConversationFactory(gig=gig)
        with pytest.raises(Exception):  # IntegrityError
            ConversationFactory(
                participant_1=conversation.participant_1,
                participant_2=conversation.participant_2,
                gig=gig,
            )

    def test_cascade_delete_participant_1(self):
        conversation = ConversationFactory()
        conversation.participant_1.delete()
        assert not Conversation.objects.filter(pk=conversation.pk).exists()

    def test_cascade_delete_participant_2(self):
        conversation = ConversationFactory()
        conversation.participant_2.delete()
        assert not Conversation.objects.filter(pk=conversation.pk).exists()


@pytest.mark.django_db
class TestMessage:
    def test_create(self):
        message = MessageFactory()
        assert message.pk is not None
        assert isinstance(message.pk, uuid.UUID)
        assert message.conversation is not None
        assert message.sender is not None
        assert message.body

    def test_str(self):
        message = MessageFactory()
        expected = f"Message from {message.sender} at {message.created}"
        assert str(message) == expected

    def test_has_timestamps(self):
        message = MessageFactory()
        assert message.created is not None
        assert message.modified is not None

    def test_read_at_null_by_default(self):
        message = MessageFactory()
        assert message.read_at is None

    def test_mark_as_read(self):
        message = MessageFactory()
        assert message.read_at is None
        message.mark_as_read()
        assert message.read_at is not None
        assert message.read_at <= timezone.now()

    def test_mark_as_read_idempotent(self):
        message = MessageFactory()
        message.mark_as_read()
        first_read = message.read_at
        message.mark_as_read()
        assert message.read_at == first_read

    def test_ordering(self):
        conversation = ConversationFactory()
        m1 = MessageFactory(conversation=conversation)
        m2 = MessageFactory(conversation=conversation)
        messages = list(Message.objects.filter(conversation=conversation))
        # Oldest first
        assert messages[0] == m1
        assert messages[1] == m2

    def test_cascade_delete_conversation(self):
        message = MessageFactory()
        conversation = message.conversation
        conversation.delete()
        assert not Message.objects.filter(pk=message.pk).exists()

    def test_cascade_delete_sender(self):
        message = MessageFactory()
        message.sender.delete()
        assert not Message.objects.filter(pk=message.pk).exists()
