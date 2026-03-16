from django.contrib import admin

from apps.messaging.models import Conversation, Message


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ["participant_1", "participant_2", "gig", "modified"]
    raw_id_fields = ["participant_1", "participant_2", "gig"]


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ["conversation", "sender", "created", "read_at"]
    raw_id_fields = ["conversation", "sender"]
