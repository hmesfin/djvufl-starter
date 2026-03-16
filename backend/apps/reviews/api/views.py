"""Views for the reviews app."""

from django.db.models import QuerySet
from rest_framework import generics, status
from rest_framework.request import Request
from rest_framework.response import Response

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.gigs.models import Gig, GigStatus
from apps.reviews.models import Review

from .serializers import ReviewCreateSerializer, ReviewSerializer


class ReviewCreateView(generics.CreateAPIView):
    """Create a review for a completed gig."""

    permission_classes = [IsVerifiedProfessional]
    serializer_class = ReviewCreateSerializer

    def create(self, request: Request, *args, **kwargs) -> Response:
        serializer = ReviewCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        profile = request.user.professional_profile
        gig_uuid = serializer.validated_data["gig_uuid"]

        try:
            gig = Gig.objects.get(id=gig_uuid, status=GigStatus.COMPLETED)
        except Gig.DoesNotExist:
            return Response(
                {"detail": "Completed gig not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Determine role
        if gig.posted_by == profile:
            is_from_poster = True
            reviewee = gig.assigned_to
        elif gig.assigned_to == profile:
            is_from_poster = False
            reviewee = gig.posted_by
        else:
            return Response(
                {"detail": "You are not a participant of this gig."},
                status=status.HTTP_403_FORBIDDEN,
            )

        if reviewee is None:
            return Response(
                {"detail": "Cannot review: gig has no assignee."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        review = Review.objects.create(
            gig=gig,
            reviewer=profile,
            reviewee=reviewee,
            rating=serializer.validated_data["rating"],
            comment=serializer.validated_data["comment"],
            is_from_poster=is_from_poster,
        )
        review = Review.objects.select_related("reviewer__user").get(pk=review.pk)
        return Response(
            ReviewSerializer(review).data,
            status=status.HTTP_201_CREATED,
        )


class ProfessionalReviewListView(generics.ListAPIView):
    """List reviews received by a professional."""

    permission_classes = [IsVerifiedProfessional]
    serializer_class = ReviewSerializer

    def get_queryset(self) -> QuerySet[Review]:
        return Review.objects.filter(
            reviewee__id=self.kwargs["uuid"]
        ).select_related("reviewer__user")
