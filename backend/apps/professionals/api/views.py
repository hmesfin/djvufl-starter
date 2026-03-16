"""Views for the professionals app."""

from decimal import Decimal, InvalidOperation

from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.professionals.models import LicenseStatus, Metro, ProfessionalProfile, ServiceArea

from .serializers import (
    MetroSerializer,
    MyProfessionalProfileSerializer,
    ProfessionalProfileCreateSerializer,
    ProfessionalProfileSerializer,
    ServiceAreaSerializer,
)


class ProfessionalProfileListView(generics.ListAPIView):
    """List verified professional profiles with filtering and search."""

    serializer_class = ProfessionalProfileSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ["is_available"]
    search_fields = ["user__first_name", "user__last_name", "bio"]
    ordering_fields = ["average_rating", "average_response_time"]
    ordering = ["-average_rating"]

    def get_queryset(self):
        qs = (
            ProfessionalProfile.objects.filter(
                license_status=LicenseStatus.VERIFIED,
            )
            .select_related("user")
            .prefetch_related("service_areas__metro")
        )

        # Custom filter: service_area (by UUID)
        service_area = self.request.query_params.get("service_area")
        if service_area:
            qs = qs.filter(service_areas__id=service_area)

        # Custom filter: min_rating
        min_rating = self.request.query_params.get("min_rating")
        if min_rating:
            try:
                qs = qs.filter(average_rating__gte=Decimal(min_rating))
            except InvalidOperation:
                pass

        # Custom filter: specializations (ArrayField contains)
        specializations = self.request.query_params.get("specializations")
        if specializations:
            qs = qs.filter(specializations__contains=[specializations])

        return qs


class ProfessionalProfileDetailView(generics.RetrieveAPIView):
    """Retrieve a single verified professional profile."""

    serializer_class = ProfessionalProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "id"
    lookup_url_kwarg = "uuid"

    def get_queryset(self):
        return (
            ProfessionalProfile.objects.filter(
                license_status=LicenseStatus.VERIFIED,
            )
            .select_related("user")
            .prefetch_related("service_areas__metro")
        )


class MyProfessionalProfileView(APIView):
    """Manage own professional profile (GET/POST/PATCH)."""

    permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: MyProfessionalProfileSerializer},
    )
    def get(self, request: Request) -> Response:
        try:
            profile = ProfessionalProfile.objects.select_related("user").prefetch_related(
                "service_areas__metro"
            ).get(user=request.user)
        except ProfessionalProfile.DoesNotExist:
            return Response(
                {"detail": "Professional profile not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = MyProfessionalProfileSerializer(profile)
        return Response(serializer.data)

    @extend_schema(
        request=ProfessionalProfileCreateSerializer,
        responses={201: MyProfessionalProfileSerializer},
    )
    def post(self, request: Request) -> Response:
        serializer = ProfessionalProfileCreateSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        profile = serializer.save()
        # Reload with relations for response
        profile = (
            ProfessionalProfile.objects.select_related("user")
            .prefetch_related("service_areas__metro")
            .get(pk=profile.pk)
        )
        response_serializer = MyProfessionalProfileSerializer(profile)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)

    @extend_schema(
        request=ProfessionalProfileCreateSerializer,
        responses={200: MyProfessionalProfileSerializer},
    )
    def patch(self, request: Request) -> Response:
        try:
            profile = ProfessionalProfile.objects.select_related("user").prefetch_related(
                "service_areas__metro"
            ).get(user=request.user)
        except ProfessionalProfile.DoesNotExist:
            return Response(
                {"detail": "Professional profile not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = ProfessionalProfileCreateSerializer(
            profile, data=request.data, partial=True, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        updated = serializer.save()
        # Reload with relations for response
        updated = (
            ProfessionalProfile.objects.select_related("user")
            .prefetch_related("service_areas__metro")
            .get(pk=updated.pk)
        )
        response_serializer = MyProfessionalProfileSerializer(updated)
        return Response(response_serializer.data)


class ServiceAreaListView(generics.ListAPIView):
    """List all service areas."""

    serializer_class = ServiceAreaSerializer
    permission_classes = [IsAuthenticated]
    queryset = ServiceArea.objects.select_related("metro").all()


class MetroListView(generics.ListAPIView):
    """List all metros."""

    serializer_class = MetroSerializer
    permission_classes = [IsAuthenticated]
    queryset = Metro.objects.all()
