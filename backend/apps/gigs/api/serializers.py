"""Serializers for the gigs app."""

from typing import Any

from rest_framework import serializers

from apps.gigs.models import Gig, GigInvitation, GigStatus, InvitationStatus
from apps.professionals.api.serializers import ProfessionalProfileSerializer
from apps.professionals.models import ProfessionalProfile, ServiceArea


class GigSerializer(serializers.ModelSerializer[Gig]):
    """Read serializer for gig list/detail."""

    uuid = serializers.UUIDField(source="id", read_only=True)
    posted_by = ProfessionalProfileSerializer(read_only=True)
    assigned_to = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Gig
        fields = [
            "uuid",
            "title",
            "description",
            "location_address",
            "location_lat",
            "location_lng",
            "scheduled_date",
            "scheduled_time",
            "budget_range_min",
            "budget_range_max",
            "agreed_price",
            "status",
            "gig_type",
            "posted_by",
            "assigned_to",
            "created",
            "modified",
        ]
        read_only_fields = [
            "uuid",
            "status",
            "posted_by",
            "assigned_to",
            "agreed_price",
            "created",
            "modified",
        ]


class GigCreateSerializer(serializers.ModelSerializer[Gig]):
    """Serializer for creating gigs."""

    service_area_uuid = serializers.UUIDField(
        write_only=True, required=False, allow_null=True, default=None
    )

    class Meta:
        model = Gig
        fields = [
            "title",
            "description",
            "location_address",
            "location_lat",
            "location_lng",
            "service_area_uuid",
            "scheduled_date",
            "scheduled_time",
            "budget_range_min",
            "budget_range_max",
            "gig_type",
        ]

    def create(self, validated_data: dict[str, Any]) -> Gig:
        service_area_uuid = validated_data.pop("service_area_uuid", None)
        profile = self.context["request"].user.professional_profile
        service_area = None
        if service_area_uuid:
            service_area = ServiceArea.objects.filter(
                id=service_area_uuid
            ).first()
        return Gig.objects.create(
            posted_by=profile,
            service_area=service_area,
            **validated_data,
        )


class GigStatusTransitionSerializer(serializers.Serializer):
    """Validates gig status transitions."""

    status = serializers.ChoiceField(choices=GigStatus.choices)

    VALID_TRANSITIONS: dict[str, list[str]] = {
        GigStatus.DRAFT: [GigStatus.POSTED, GigStatus.CANCELLED],
        GigStatus.POSTED: [GigStatus.INVITED, GigStatus.CANCELLED],
        GigStatus.INVITED: [GigStatus.NEGOTIATING, GigStatus.CANCELLED],
        GigStatus.NEGOTIATING: [GigStatus.ACCEPTED, GigStatus.CANCELLED],
        GigStatus.ACCEPTED: [GigStatus.IN_PROGRESS, GigStatus.CANCELLED],
        GigStatus.IN_PROGRESS: [GigStatus.COMPLETED, GigStatus.DISPUTED],
        GigStatus.COMPLETED: [],
        GigStatus.CANCELLED: [],
        GigStatus.DISPUTED: [GigStatus.COMPLETED],
    }

    def validate_status(self, value: str) -> str:
        gig = self.context["gig"]
        allowed = self.VALID_TRANSITIONS.get(gig.status, [])
        if value not in allowed:
            raise serializers.ValidationError(
                f"Cannot transition from '{gig.status}' to '{value}'. "
                f"Allowed transitions: {allowed}"
            )
        return value


class GigInvitationSerializer(serializers.ModelSerializer[GigInvitation]):
    """Read serializer for gig invitations."""

    uuid = serializers.UUIDField(source="id", read_only=True)
    invited_agent = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = GigInvitation
        fields = [
            "uuid",
            "invited_agent",
            "proposed_rate",
            "message",
            "status",
            "created",
        ]
        read_only_fields = ["uuid", "invited_agent", "created"]


class GigInvitationCreateSerializer(serializers.Serializer):
    """Serializer for creating gig invitations."""

    invited_agent_uuid = serializers.UUIDField()
    message = serializers.CharField(required=False, default="")

    def validate_invited_agent_uuid(self, value: Any) -> Any:
        try:
            profile = ProfessionalProfile.objects.get(id=value)
        except ProfessionalProfile.DoesNotExist:
            raise serializers.ValidationError("Agent not found.")
        if profile.license_status != "verified":
            raise serializers.ValidationError(
                "Agent must be verified to be invited."
            )
        return value

    def create(self, validated_data: dict[str, Any]) -> GigInvitation:
        gig = self.context["gig"]
        agent = ProfessionalProfile.objects.get(
            id=validated_data["invited_agent_uuid"]
        )
        return GigInvitation.objects.create(
            gig=gig,
            invited_agent=agent,
            message=validated_data.get("message", ""),
        )
