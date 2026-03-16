"""Views for the messaging app."""

from typing import cast

from django.db.models import Q, QuerySet
from rest_framework import generics, status
from rest_framework.request import Request
from rest_framework.response import Response

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.gigs.models import Gig
from apps.messaging.models import Conversation, Message
from apps.professionals.models import ProfessionalProfile
from apps.users.models import User

from .serializers import (
    ConversationCreateSerializer,
    ConversationSerializer,
    MessageCreateSerializer,
    MessageSerializer,
)


class ConversationListCreateView(generics.ListCreateAPIView):
    """List and create conversations."""

    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return ConversationCreateSerializer
        return ConversationSerializer

    def get_queryset(self) -> QuerySet[Conversation]:
        user = cast(User, self.request.user)
        profile = user.professional_profile
        return Conversation.objects.filter(
            Q(participant_1=profile) | Q(participant_2=profile)
        ).select_related(
            "participant_1__user",
            "participant_2__user",
        )

    def create(self, request: Request, *args, **kwargs) -> Response:
        serializer = ConversationCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = cast(User, request.user)
        profile = user.professional_profile
        participant_uuid = serializer.validated_data["participant_uuid"]
        gig_uuid = serializer.validated_data.get("gig_uuid")

        # Can't message yourself
        if str(profile.id) == str(participant_uuid):
            return Response(
                {"detail": "You cannot create a conversation with yourself."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Resolve participant
        try:
            other = ProfessionalProfile.objects.get(id=participant_uuid)
        except ProfessionalProfile.DoesNotExist:
            return Response(
                {"detail": "Participant not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Resolve gig if provided
        gig = None
        if gig_uuid:
            try:
                gig = Gig.objects.get(id=gig_uuid)
            except Gig.DoesNotExist:
                return Response(
                    {"detail": "Gig not found."},
                    status=status.HTTP_404_NOT_FOUND,
                )

        # Check for existing conversation (in either direction)
        existing = Conversation.objects.filter(
            Q(participant_1=profile, participant_2=other)
            | Q(participant_1=other, participant_2=profile),
            gig=gig,
        ).first()

        if existing:
            data = ConversationSerializer(
                existing, context={"request": request}
            ).data
            return Response(data, status=status.HTTP_200_OK)

        # Create new conversation
        conversation = Conversation.objects.create(
            participant_1=profile,
            participant_2=other,
            gig=gig,
        )
        conversation = (
            Conversation.objects.select_related(
                "participant_1__user", "participant_2__user"
            ).get(pk=conversation.pk)
        )
        data = ConversationSerializer(
            conversation, context={"request": request}
        ).data
        return Response(data, status=status.HTTP_201_CREATED)


class MessageListCreateView(generics.ListCreateAPIView):
    """List and create messages in a conversation."""

    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return MessageCreateSerializer
        return MessageSerializer

    def _get_conversation(self) -> Conversation:
        return Conversation.objects.get(id=self.kwargs["conversation_uuid"])

    def _check_participant(self, request: Request, conversation: Conversation) -> bool:
        user = cast(User, request.user)
        profile = user.professional_profile
        return profile in (conversation.participant_1, conversation.participant_2)

    def get_queryset(self) -> QuerySet[Message]:
        return Message.objects.filter(
            conversation__id=self.kwargs["conversation_uuid"]
        ).select_related("sender__user")

    def list(self, request: Request, *args, **kwargs) -> Response:
        try:
            conversation = self._get_conversation()
        except Conversation.DoesNotExist:
            return Response(
                {"detail": "Conversation not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if not self._check_participant(request, conversation):
            return Response(
                {"detail": "You are not a participant in this conversation."},
                status=status.HTTP_403_FORBIDDEN,
            )

        return super().list(request, *args, **kwargs)

    def create(self, request: Request, *args, **kwargs) -> Response:
        try:
            conversation = self._get_conversation()
        except Conversation.DoesNotExist:
            return Response(
                {"detail": "Conversation not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if not self._check_participant(request, conversation):
            return Response(
                {"detail": "You are not a participant in this conversation."},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = MessageCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = cast(User, request.user)
        profile = user.professional_profile
        message = Message.objects.create(
            conversation=conversation,
            sender=profile,
            body=serializer.validated_data["body"],
        )

        # Update conversation modified timestamp
        conversation.save(update_fields=["modified"])

        message = Message.objects.select_related("sender__user").get(pk=message.pk)
        return Response(
            MessageSerializer(message).data,
            status=status.HTTP_201_CREATED,
        )
