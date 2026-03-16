"""Serializers for the professionals app."""

from typing import Any

from rest_framework import serializers

from apps.professionals.models import Metro, ProfessionalProfile, ServiceArea


class MetroSerializer(serializers.ModelSerializer[Metro]):
    uuid = serializers.UUIDField(source="id", read_only=True)

    class Meta:
        model = Metro
        fields = ["uuid", "name", "state"]
        read_only_fields = ["uuid"]


class ServiceAreaSerializer(serializers.ModelSerializer[ServiceArea]):
    uuid = serializers.UUIDField(source="id", read_only=True)
    metro = MetroSerializer(read_only=True)

    class Meta:
        model = ServiceArea
        fields = ["uuid", "name", "zip_codes", "metro"]


class ProfessionalProfileSerializer(
    serializers.ModelSerializer[ProfessionalProfile],
):
    """Read-only serializer for viewing professional profiles (public)."""

    uuid = serializers.UUIDField(source="id", read_only=True)
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_first_name = serializers.CharField(
        source="user.first_name", read_only=True
    )
    user_last_name = serializers.CharField(
        source="user.last_name", read_only=True
    )
    user_avatar = serializers.ImageField(
        source="user.avatar", read_only=True
    )
    service_areas = ServiceAreaSerializer(many=True, read_only=True)
    is_verified = serializers.BooleanField(read_only=True)

    class Meta:
        model = ProfessionalProfile
        fields = [
            "uuid",
            "user_email",
            "user_first_name",
            "user_last_name",
            "user_avatar",
            "license_status",
            "service_areas",
            "specializations",
            "bio",
            "average_rating",
            "average_response_time",
            "is_available",
            "is_verified",
        ]
        read_only_fields = fields


class ProfessionalProfileCreateSerializer(
    serializers.ModelSerializer[ProfessionalProfile],
):
    """Serializer for creating/updating own professional profile."""

    service_area_uuids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False,
        default=list,
    )

    class Meta:
        model = ProfessionalProfile
        fields = [
            "license_number",
            "bio",
            "specializations",
            "is_available",
            "service_area_uuids",
        ]

    def create(self, validated_data: dict[str, Any]) -> ProfessionalProfile:
        service_area_uuids = validated_data.pop("service_area_uuids", [])
        user = self.context["request"].user
        profile = ProfessionalProfile.objects.create(user=user, **validated_data)
        if service_area_uuids:
            areas = ServiceArea.objects.filter(id__in=service_area_uuids)
            profile.service_areas.set(areas)
        return profile

    def update(
        self,
        instance: ProfessionalProfile,
        validated_data: dict[str, Any],
    ) -> ProfessionalProfile:
        service_area_uuids = validated_data.pop("service_area_uuids", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if service_area_uuids is not None:
            areas = ServiceArea.objects.filter(id__in=service_area_uuids)
            instance.service_areas.set(areas)
        return instance


class MyProfessionalProfileSerializer(ProfessionalProfileSerializer):
    """Extended serializer that includes private fields for the profile owner."""

    has_stripe_account = serializers.SerializerMethodField()

    class Meta(ProfessionalProfileSerializer.Meta):
        fields = [
            *ProfessionalProfileSerializer.Meta.fields,
            "license_number",
            "license_expiry",
            "verified_at",
            "rejection_reason",
            "has_stripe_account",
        ]
        read_only_fields = fields

    def get_has_stripe_account(self, obj: ProfessionalProfile) -> bool:
        """Return whether the professional has connected a Stripe account."""
        return bool(obj.stripe_connect_account_id)
