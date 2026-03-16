"""Serializers for the messaging app."""

from rest_framework import serializers

from apps.messaging.models import Conversation, Message
from apps.professionals.api.serializers import ProfessionalProfileSerializer


class MessageSerializer(serializers.ModelSerializer[Message]):
    uuid = serializers.UUIDField(source="id", read_only=True)
    sender = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ["uuid", "sender", "body", "read_at", "created"]
        read_only_fields = ["uuid", "sender", "read_at", "created"]


class MessageCreateSerializer(serializers.Serializer):
    body = serializers.CharField()


class ConversationSerializer(serializers.ModelSerializer[Conversation]):
    uuid = serializers.UUIDField(source="id", read_only=True)
    participant_1 = ProfessionalProfileSerializer(read_only=True)
    participant_2 = ProfessionalProfileSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    gig = serializers.UUIDField(source="gig_id", read_only=True)

    class Meta:
        model = Conversation
        fields = [
            "uuid",
            "participant_1",
            "participant_2",
            "gig",
            "last_message",
            "unread_count",
            "modified",
        ]

    def get_last_message(self, obj: Conversation) -> dict | None:
        last = obj.messages.order_by("-created").first()
        if last is None:
            return None
        return MessageSerializer(last).data

    def get_unread_count(self, obj: Conversation) -> int:
        request = self.context.get("request")
        if request and hasattr(request.user, "professional_profile"):
            profile = request.user.professional_profile
            return obj.messages.filter(read_at__isnull=True).exclude(
                sender=profile
            ).count()
        return 0


class ConversationCreateSerializer(serializers.Serializer):
    participant_uuid = serializers.UUIDField()
    gig_uuid = serializers.UUIDField(required=False, allow_null=True, default=None)
