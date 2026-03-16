"""Tests for messaging app views."""

import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.gigs.tests.factories import GigFactory
from apps.messaging.models import Conversation, Message
from apps.messaging.tests.factories import ConversationFactory, MessageFactory
from apps.professionals.models import LicenseStatus
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


@pytest.fixture()
def api_client() -> APIClient:
    return APIClient()


@pytest.fixture()
def verified_agent(api_client: APIClient) -> tuple[APIClient, object, object]:
    """Return (authenticated client, user, verified professional profile)."""
    user = UserFactory()
    profile = ProfessionalProfileFactory(
        user=user, license_status=LicenseStatus.VERIFIED
    )
    api_client.force_authenticate(user=user)
    return api_client, user, profile


class TestListConversations:
    url = reverse("api:conversation-list")

    def test_list_conversations(self, verified_agent: tuple) -> None:
        """Authenticated user sees their conversations."""
        client, user, profile = verified_agent
        other = ProfessionalProfileFactory(license_status="verified")
        ConversationFactory(participant_1=profile, participant_2=other)
        ConversationFactory(participant_1=other, participant_2=profile)

        response = client.get(self.url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 2

    def test_only_own_conversations(self, verified_agent: tuple) -> None:
        """User doesn't see other people's conversations."""
        client, user, profile = verified_agent
        # Conversation between two other people
        ConversationFactory()
        # Conversation involving this user
        ConversationFactory(participant_1=profile)

        response = client.get(self.url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_unauthenticated(self, api_client: APIClient) -> None:
        response = api_client.get(self.url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_unverified_forbidden(self, api_client: APIClient) -> None:
        user = UserFactory()
        ProfessionalProfileFactory(
            user=user, license_status=LicenseStatus.PENDING
        )
        api_client.force_authenticate(user=user)
        response = api_client.get(self.url)
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestCreateConversation:
    url = reverse("api:conversation-list")

    def test_create_conversation(self, verified_agent: tuple) -> None:
        """Creates a new conversation."""
        client, user, profile = verified_agent
        other = ProfessionalProfileFactory(license_status="verified")

        response = client.post(
            self.url,
            {"participant_uuid": str(other.id)},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert Conversation.objects.count() == 1

    def test_create_conversation_with_gig(self, verified_agent: tuple) -> None:
        """Creates a new conversation linked to a gig."""
        client, user, profile = verified_agent
        other = ProfessionalProfileFactory(license_status="verified")
        gig = GigFactory(posted_by=profile)

        response = client.post(
            self.url,
            {"participant_uuid": str(other.id), "gig_uuid": str(gig.id)},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert Conversation.objects.count() == 1
        assert response.data["gig"] == str(gig.id)

    def test_returns_existing_conversation(self, verified_agent: tuple) -> None:
        """Doesn't duplicate -- returns existing conversation."""
        client, user, profile = verified_agent
        other = ProfessionalProfileFactory(license_status="verified")
        existing = ConversationFactory(participant_1=profile, participant_2=other)

        response = client.post(
            self.url,
            {"participant_uuid": str(other.id)},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert Conversation.objects.count() == 1
        assert response.data["uuid"] == str(existing.id)

    def test_cannot_message_self(self, verified_agent: tuple) -> None:
        """Can't create a conversation with yourself."""
        client, user, profile = verified_agent

        response = client.post(
            self.url,
            {"participant_uuid": str(profile.id)},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


class TestListMessages:
    def _url(self, conversation_uuid: str) -> str:
        return reverse(
            "api:message-list",
            kwargs={"conversation_uuid": conversation_uuid},
        )

    def test_list_messages(self, verified_agent: tuple) -> None:
        """Shows messages in order."""
        client, user, profile = verified_agent
        conversation = ConversationFactory(participant_1=profile)
        m1 = MessageFactory(conversation=conversation, sender=profile)
        m2 = MessageFactory(
            conversation=conversation,
            sender=conversation.participant_2,
        )

        response = client.get(self._url(conversation.id))
        assert response.status_code == status.HTTP_200_OK
        results = response.data["results"]
        assert len(results) == 2
        # Oldest first
        assert results[0]["uuid"] == str(m1.id)
        assert results[1]["uuid"] == str(m2.id)

    def test_non_participant_cannot_access(self, verified_agent: tuple) -> None:
        """403 for non-participants."""
        client, user, profile = verified_agent
        conversation = ConversationFactory()  # between two other people

        response = client.get(self._url(conversation.id))
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestSendMessage:
    def _url(self, conversation_uuid: str) -> str:
        return reverse(
            "api:message-list",
            kwargs={"conversation_uuid": conversation_uuid},
        )

    def test_send_message(self, verified_agent: tuple) -> None:
        """Creates message in conversation."""
        client, user, profile = verified_agent
        conversation = ConversationFactory(participant_1=profile)

        response = client.post(
            self._url(conversation.id),
            {"body": "Hello!"},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert Message.objects.count() == 1
        assert response.data["body"] == "Hello!"
        assert response.data["sender"]["uuid"] == str(profile.id)

    def test_non_participant_cannot_send(self, verified_agent: tuple) -> None:
        """Non-participant can't send messages."""
        client, user, profile = verified_agent
        conversation = ConversationFactory()

        response = client.post(
            self._url(conversation.id),
            {"body": "Hello!"},
            format="json",
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_send_updates_conversation_modified(self, verified_agent: tuple) -> None:
        """Sending a message updates the conversation's modified timestamp."""
        client, user, profile = verified_agent
        conversation = ConversationFactory(participant_1=profile)
        old_modified = conversation.modified

        response = client.post(
            self._url(conversation.id),
            {"body": "Hello!"},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        conversation.refresh_from_db()
        assert conversation.modified >= old_modified
