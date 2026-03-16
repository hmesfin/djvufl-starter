"""Models for the messaging app."""

from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel


class Conversation(BaseModel):
    """A conversation between two professional profiles, optionally tied to a gig."""

    participant_1 = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="conversations_as_p1",
        verbose_name=_("participant 1"),
    )
    participant_2 = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="conversations_as_p2",
        verbose_name=_("participant 2"),
    )
    gig = models.ForeignKey(
        "gigs.Gig",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="conversations",
        verbose_name=_("gig"),
    )

    class Meta:
        ordering = ["-modified"]
        unique_together = ["participant_1", "participant_2", "gig"]

    def __str__(self) -> str:
        return f"Conversation between {self.participant_1} and {self.participant_2}"


class Message(BaseModel):
    """A message within a conversation."""

    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.CASCADE,
        related_name="messages",
        verbose_name=_("conversation"),
    )
    sender = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="sent_messages",
        verbose_name=_("sender"),
    )
    body = models.TextField(_("body"))
    read_at = models.DateTimeField(_("read at"), null=True, blank=True)

    class Meta:
        ordering = ["created"]

    def __str__(self) -> str:
        return f"Message from {self.sender} at {self.created}"

    def mark_as_read(self) -> None:
        """Mark the message as read if not already read."""
        if self.read_at is None:
            self.read_at = timezone.now()
            self.save(update_fields=["read_at"])
