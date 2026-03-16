"""Serializers for the reviews app."""

from rest_framework import serializers

from apps.professionals.api.serializers import ProfessionalProfileSerializer
from apps.reviews.models import Review


class ReviewCreateSerializer(serializers.Serializer):
    gig_uuid = serializers.UUIDField()
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, default="")


class ReviewSerializer(serializers.ModelSerializer[Review]):
    uuid = serializers.UUIDField(source="id", read_only=True)
    reviewer = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Review
        fields = ["uuid", "reviewer", "rating", "comment", "is_from_poster", "created"]
        read_only_fields = fields
