# RealGig Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a two-sided marketplace for verified real estate agents in the MSP metro to find and hire each other for gig work (showings, open houses, etc.).

**Architecture:** Monolithic extension of existing Django 5.2 + Vue 3 + Flutter stack. Five new Django apps (professionals, gigs, messaging, reviews, payments) with corresponding Vue frontend views. Stripe Connect Express for payments. Manual license verification at launch, automated later.

**Tech Stack:** Django 5.2, DRF, PostgreSQL, Celery, Redis, Vue 3 (Composition API), TypeScript, Shadcn-vue, Tailwind CSS v4, Stripe Connect, Flutter (Riverpod)

**Design Doc:** `docs/plans/2026-03-16-real-estate-agent-marketplace-design.md`

---

## Phase 1: Backend Foundation

### Task 1: Remove Projects App (Cleanup)

The `projects` app is demo scaffolding from the starter template. Remove it before building new apps.

**Files:**
- Delete: `backend/apps/projects/` (entire directory)
- Modify: `backend/config/settings/base.py` (remove from INSTALLED_APPS)
- Modify: `backend/config/api_router.py` (remove project routes)
- Modify: `backend/config/settings/base.py` (remove ENUM_NAME_OVERRIDES for projects)
- Delete: `frontend/src/views/projects/` (entire directory)
- Modify: `frontend/src/router/index.ts` (remove project routes)
- Delete: `frontend/src/composables/useProjects.ts`
- Delete: `frontend/src/constants/projects.ts` (if exists)

**Step 1: Remove projects from INSTALLED_APPS**

In `backend/config/settings/base.py`, remove `"apps.projects"` from `LOCAL_APPS`.

**Step 2: Remove projects from api_router.py**

In `backend/config/api_router.py`, remove all project-related imports and route registrations.

**Step 3: Remove ENUM_NAME_OVERRIDES for projects**

In `backend/config/settings/base.py`, remove the `StatusEnum` and `PriorityEnum` entries from `SPECTACULAR_SETTINGS["ENUM_NAME_OVERRIDES"]`.

**Step 4: Delete the projects app directory**

```bash
rm -rf backend/apps/projects/
```

**Step 5: Create migration to drop projects table**

```bash
docker compose run --rm django python manage.py makemigrations --empty users --name remove_projects_references
docker compose run --rm django python manage.py migrate
```

Note: Since projects has its own migrations directory which we deleted, we need to handle this carefully. The simplest approach: reset migrations if no production data exists yet. If the database is dev-only:

```bash
docker compose down -v
docker compose up -d postgres
docker compose run --rm django python manage.py migrate
```

**Step 6: Remove frontend project files**

```bash
rm -rf frontend/src/views/projects/
rm -f frontend/src/composables/useProjects.ts
rm -f frontend/src/constants/projects.ts
```

**Step 7: Remove project routes from frontend router**

In `frontend/src/router/index.ts`, remove the `projects` and `projects/:uuid` route entries under the dashboard layout.

**Step 8: Verify everything still works**

```bash
docker compose run --rm django pytest
docker compose run --rm frontend npm run type-check
```

**Step 9: Commit**

```bash
git add -A
git commit -m "chore: remove demo projects app to make room for RealGig"
```

---

### Task 2: Create Professionals App -- Models

**Files:**
- Create: `backend/apps/professionals/` (new Django app)
- Create: `backend/apps/professionals/models.py`
- Create: `backend/apps/professionals/admin.py`
- Create: `backend/apps/professionals/apps.py`
- Create: `backend/apps/professionals/tests/__init__.py`
- Create: `backend/apps/professionals/tests/factories.py`
- Create: `backend/apps/professionals/tests/test_models.py`
- Modify: `backend/config/settings/base.py` (add to INSTALLED_APPS)

**Step 1: Create the Django app**

Run locally (not in Docker, to avoid root ownership):

```bash
cd backend && python manage.py startapp professionals apps/professionals && cd ..
```

**Step 2: Configure apps.py**

```python
# backend/apps/professionals/apps.py
from django.apps import AppConfig


class ProfessionalsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.professionals"
    verbose_name = "Professionals"
```

**Step 3: Add to INSTALLED_APPS**

In `backend/config/settings/base.py`, add `"apps.professionals"` to `LOCAL_APPS`.

**Step 4: Write failing tests for Metro model**

```python
# backend/apps/professionals/tests/test_models.py
import pytest
from apps.professionals.tests.factories import MetroFactory


@pytest.mark.django_db
class TestMetro:
    def test_create_metro(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        assert metro.name == "Minneapolis-St. Paul"
        assert metro.state == "MN"

    def test_str_representation(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        assert str(metro) == "Minneapolis-St. Paul, MN"
```

**Step 5: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py -v
```

Expected: FAIL (no factories, no models yet)

**Step 6: Create factories**

```python
# backend/apps/professionals/tests/factories.py
import factory
from apps.professionals.models import Metro, ServiceArea, ProfessionalProfile
from apps.users.tests.factories import UserFactory


class MetroFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Metro

    name = factory.Sequence(lambda n: f"Metro {n}")
    state = "MN"


class ServiceAreaFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ServiceArea

    name = factory.Sequence(lambda n: f"Area {n}")
    metro = factory.SubFactory(MetroFactory)

    @factory.lazy_attribute
    def zip_codes(self):
        return ["55401", "55402"]


class ProfessionalProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ProfessionalProfile

    user = factory.SubFactory(UserFactory)
    license_number = factory.Sequence(lambda n: f"MN-RE-{n:06d}")
    license_status = "pending_verification"
    bio = factory.Faker("paragraph")
    is_available = True

    @factory.post_generation
    def service_areas(self, create, extracted, **kwargs):
        if not create or not extracted:
            return
        self.service_areas.add(*extracted)
```

**Step 7: Write the Metro model**

```python
# backend/apps/professionals/models.py
from django.conf import settings
from django.contrib.postgres.fields import ArrayField
from django.db import models

from apps.shared.models import BaseModel


class Metro(BaseModel):
    name = models.CharField(max_length=255)
    state = models.CharField(max_length=2)

    class Meta:
        ordering = ["name"]
        unique_together = ["name", "state"]

    def __str__(self) -> str:
        return f"{self.name}, {self.state}"
```

**Step 8: Run Metro tests**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py::TestMetro -v
```

Expected: PASS

**Step 9: Write failing tests for ServiceArea model**

```python
# Append to backend/apps/professionals/tests/test_models.py
from apps.professionals.tests.factories import ServiceAreaFactory, MetroFactory


@pytest.mark.django_db
class TestServiceArea:
    def test_create_service_area(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        area = ServiceAreaFactory(
            name="Downtown Minneapolis",
            zip_codes=["55401", "55402", "55403"],
            metro=metro,
        )
        assert area.name == "Downtown Minneapolis"
        assert area.zip_codes == ["55401", "55402", "55403"]
        assert area.metro == metro

    def test_str_representation(self):
        area = ServiceAreaFactory(name="Edina")
        assert str(area) == "Edina"
```

**Step 10: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py::TestServiceArea -v
```

Expected: FAIL

**Step 11: Write the ServiceArea model**

```python
# Add to backend/apps/professionals/models.py
class ServiceArea(BaseModel):
    name = models.CharField(max_length=255)
    zip_codes = ArrayField(
        models.CharField(max_length=10),
        default=list,
        blank=True,
    )
    metro = models.ForeignKey(
        Metro,
        on_delete=models.CASCADE,
        related_name="service_areas",
    )

    class Meta:
        ordering = ["name"]
        unique_together = ["name", "metro"]

    def __str__(self) -> str:
        return self.name
```

**Step 12: Run ServiceArea tests**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py::TestServiceArea -v
```

Expected: PASS

**Step 13: Write failing tests for ProfessionalProfile model**

```python
# Append to backend/apps/professionals/tests/test_models.py
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.users.tests.factories import UserFactory


@pytest.mark.django_db
class TestProfessionalProfile:
    def test_create_profile(self):
        profile = ProfessionalProfileFactory()
        assert profile.license_number.startswith("MN-RE-")
        assert profile.license_status == "pending_verification"
        assert profile.is_available is True
        assert profile.average_rating is None
        assert profile.average_response_time is None

    def test_profile_linked_to_user(self):
        user = UserFactory()
        profile = ProfessionalProfileFactory(user=user)
        assert profile.user == user
        assert profile.user.email == user.email

    def test_profile_service_areas(self):
        area1 = ServiceAreaFactory(name="Downtown")
        area2 = ServiceAreaFactory(name="Uptown")
        profile = ProfessionalProfileFactory(service_areas=[area1, area2])
        assert profile.service_areas.count() == 2

    def test_str_representation(self):
        user = UserFactory(first_name="Jane", last_name="Doe")
        profile = ProfessionalProfileFactory(user=user)
        assert str(profile) == "Jane Doe"

    def test_license_status_choices(self):
        profile = ProfessionalProfileFactory(license_status="verified")
        assert profile.license_status == "verified"

    def test_specializations(self):
        profile = ProfessionalProfileFactory()
        profile.specializations = ["residential", "buyers_agent"]
        profile.save()
        profile.refresh_from_db()
        assert "residential" in profile.specializations

    def test_one_profile_per_user(self):
        """Each user can only have one professional profile."""
        user = UserFactory()
        ProfessionalProfileFactory(user=user)
        with pytest.raises(Exception):  # IntegrityError
            ProfessionalProfileFactory(user=user)
```

**Step 14: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py::TestProfessionalProfile -v
```

Expected: FAIL

**Step 15: Write the ProfessionalProfile model**

```python
# Add to backend/apps/professionals/models.py
class LicenseStatus(models.TextChoices):
    PENDING = "pending_verification", "Pending Verification"
    VERIFIED = "verified", "Verified"
    REJECTED = "rejected", "Rejected"
    EXPIRED = "expired", "Expired"


class Specialization(models.TextChoices):
    RESIDENTIAL = "residential", "Residential"
    COMMERCIAL = "commercial", "Commercial"
    BUYERS_AGENT = "buyers_agent", "Buyer's Agent"
    LISTING_AGENT = "listing_agent", "Listing Agent"


class ProfessionalProfile(BaseModel):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="professional_profile",
    )
    license_number = models.CharField(max_length=50, unique=True)
    license_status = models.CharField(
        max_length=25,
        choices=LicenseStatus.choices,
        default=LicenseStatus.PENDING,
    )
    license_expiry = models.DateField(null=True, blank=True)
    service_areas = models.ManyToManyField(
        ServiceArea,
        related_name="professionals",
        blank=True,
    )
    specializations = ArrayField(
        models.CharField(max_length=30, choices=Specialization.choices),
        default=list,
        blank=True,
    )
    bio = models.TextField(blank=True)
    average_rating = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        null=True,
        blank=True,
    )
    average_response_time = models.DurationField(null=True, blank=True)
    is_available = models.BooleanField(default=True)
    stripe_connect_account_id = models.CharField(
        max_length=255, blank=True, default=""
    )
    verified_at = models.DateTimeField(null=True, blank=True)
    verified_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="verifications_performed",
    )
    last_reverification_check = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-average_rating"]
        indexes = [
            models.Index(fields=["license_status"]),
            models.Index(fields=["is_available"]),
            models.Index(fields=["license_number"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.first_name} {self.user.last_name}"

    @property
    def is_verified(self) -> bool:
        return self.license_status == LicenseStatus.VERIFIED
```

**Step 16: Create and run migrations**

```bash
docker compose run --rm django python manage.py makemigrations professionals
docker compose run --rm django python manage.py migrate
```

**Step 17: Run all ProfessionalProfile tests**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_models.py -v
```

Expected: ALL PASS

**Step 18: Write admin configuration**

```python
# backend/apps/professionals/admin.py
from django.contrib import admin

from apps.professionals.models import Metro, ProfessionalProfile, ServiceArea


@admin.register(Metro)
class MetroAdmin(admin.ModelAdmin):
    list_display = ["name", "state"]
    search_fields = ["name"]


@admin.register(ServiceArea)
class ServiceAreaAdmin(admin.ModelAdmin):
    list_display = ["name", "metro"]
    list_filter = ["metro"]
    search_fields = ["name", "zip_codes"]


@admin.register(ProfessionalProfile)
class ProfessionalProfileAdmin(admin.ModelAdmin):
    list_display = [
        "user",
        "license_number",
        "license_status",
        "is_available",
        "average_rating",
    ]
    list_filter = ["license_status", "is_available"]
    search_fields = ["user__email", "user__first_name", "user__last_name", "license_number"]
    readonly_fields = ["verified_at", "verified_by", "average_rating", "average_response_time"]
    raw_id_fields = ["user", "verified_by"]
```

**Step 19: Commit**

```bash
git add -A
git commit -m "feat(professionals): add Metro, ServiceArea, ProfessionalProfile models with tests"
```

---

### Task 3: Professionals App -- Serializers & API

**Files:**
- Create: `backend/apps/professionals/api/__init__.py`
- Create: `backend/apps/professionals/api/serializers.py`
- Create: `backend/apps/professionals/api/views.py`
- Create: `backend/apps/professionals/tests/test_views.py`
- Modify: `backend/config/api_router.py`

**Step 1: Write failing tests for serializers**

```python
# backend/apps/professionals/tests/test_serializers.py
import pytest
from apps.professionals.api.serializers import (
    ProfessionalProfileSerializer,
    ProfessionalProfileCreateSerializer,
    ServiceAreaSerializer,
    MetroSerializer,
)
from apps.professionals.tests.factories import (
    ProfessionalProfileFactory,
    ServiceAreaFactory,
    MetroFactory,
)


@pytest.mark.django_db
class TestMetroSerializer:
    def test_serializes_metro(self):
        metro = MetroFactory(name="Minneapolis-St. Paul", state="MN")
        serializer = MetroSerializer(metro)
        assert serializer.data["name"] == "Minneapolis-St. Paul"
        assert serializer.data["state"] == "MN"


@pytest.mark.django_db
class TestServiceAreaSerializer:
    def test_serializes_service_area(self):
        area = ServiceAreaFactory(name="Downtown Minneapolis", zip_codes=["55401"])
        serializer = ServiceAreaSerializer(area)
        assert serializer.data["name"] == "Downtown Minneapolis"
        assert serializer.data["zip_codes"] == ["55401"]
        assert "metro" in serializer.data


@pytest.mark.django_db
class TestProfessionalProfileSerializer:
    def test_serializes_profile(self):
        area = ServiceAreaFactory()
        profile = ProfessionalProfileFactory(service_areas=[area])
        serializer = ProfessionalProfileSerializer(profile)
        data = serializer.data
        assert "uuid" in data
        assert "license_status" in data
        assert "service_areas" in data
        assert "user_email" in data
        assert "user_first_name" in data
        assert "user_last_name" in data
        assert "is_verified" in data
        # Should NOT expose license_number to other users
        assert "license_number" not in data

    def test_does_not_expose_stripe_id(self):
        profile = ProfessionalProfileFactory()
        serializer = ProfessionalProfileSerializer(profile)
        assert "stripe_connect_account_id" not in serializer.data


@pytest.mark.django_db
class TestProfessionalProfileCreateSerializer:
    def test_create_profile(self):
        from apps.users.tests.factories import UserFactory
        user = UserFactory()
        data = {
            "license_number": "MN-RE-123456",
            "bio": "10 years experience in residential real estate.",
            "specializations": ["residential", "buyers_agent"],
        }
        serializer = ProfessionalProfileCreateSerializer(
            data=data, context={"request": type("Request", (), {"user": user})()}
        )
        assert serializer.is_valid(), serializer.errors
        profile = serializer.save()
        assert profile.user == user
        assert profile.license_status == "pending_verification"
```

**Step 2: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_serializers.py -v
```

Expected: FAIL

**Step 3: Write serializers**

```python
# backend/apps/professionals/api/__init__.py
```

```python
# backend/apps/professionals/api/serializers.py
from rest_framework import serializers

from apps.professionals.models import Metro, ProfessionalProfile, ServiceArea


class MetroSerializer(serializers.ModelSerializer):
    class Meta:
        model = Metro
        fields = ["uuid", "name", "state"]
        read_only_fields = ["uuid"]


class ServiceAreaSerializer(serializers.ModelSerializer):
    metro = MetroSerializer(read_only=True)

    class Meta:
        model = ServiceArea
        fields = ["uuid", "name", "zip_codes", "metro"]
        read_only_fields = ["uuid"]


class ProfessionalProfileSerializer(serializers.ModelSerializer):
    """Read-only serializer for viewing other agents' profiles."""

    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_first_name = serializers.CharField(source="user.first_name", read_only=True)
    user_last_name = serializers.CharField(source="user.last_name", read_only=True)
    user_avatar = serializers.ImageField(source="user.avatar", read_only=True)
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


class ProfessionalProfileCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating/updating own profile."""

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

    def create(self, validated_data: dict) -> ProfessionalProfile:
        service_area_uuids = validated_data.pop("service_area_uuids", [])
        user = self.context["request"].user
        profile = ProfessionalProfile.objects.create(user=user, **validated_data)
        if service_area_uuids:
            areas = ServiceArea.objects.filter(uuid__in=service_area_uuids)
            profile.service_areas.set(areas)
        return profile

    def update(self, instance: ProfessionalProfile, validated_data: dict) -> ProfessionalProfile:
        service_area_uuids = validated_data.pop("service_area_uuids", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if service_area_uuids is not None:
            areas = ServiceArea.objects.filter(uuid__in=service_area_uuids)
            instance.service_areas.set(areas)
        return instance


class MyProfessionalProfileSerializer(ProfessionalProfileSerializer):
    """Extended serializer for viewing own profile (includes private fields)."""

    class Meta(ProfessionalProfileSerializer.Meta):
        fields = ProfessionalProfileSerializer.Meta.fields + [
            "license_number",
            "license_expiry",
            "verified_at",
            "rejection_reason",
        ]
```

**Step 4: Run serializer tests**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_serializers.py -v
```

Expected: PASS

**Step 5: Write failing tests for API views**

```python
# backend/apps/professionals/tests/test_views.py
import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.professionals.tests.factories import (
    ProfessionalProfileFactory,
    ServiceAreaFactory,
)
from apps.users.tests.factories import UserFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def authenticated_client(api_client):
    user = UserFactory(is_email_verified=True)
    api_client.force_authenticate(user=user)
    return api_client, user


@pytest.mark.django_db
class TestProfessionalProfileList:
    def test_list_only_verified_profiles(self, authenticated_client):
        client, _ = authenticated_client
        ProfessionalProfileFactory(license_status="verified")
        ProfessionalProfileFactory(license_status="verified")
        ProfessionalProfileFactory(license_status="pending_verification")
        response = client.get(reverse("api:professional-list"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 2  # Only verified

    def test_filter_by_service_area(self, authenticated_client):
        client, _ = authenticated_client
        area = ServiceAreaFactory(name="Downtown")
        profile = ProfessionalProfileFactory(license_status="verified", service_areas=[area])
        ProfessionalProfileFactory(license_status="verified")  # no area
        response = client.get(
            reverse("api:professional-list"),
            {"service_area": str(area.uuid)},
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1
        assert response.data["results"][0]["uuid"] == str(profile.uuid)

    def test_filter_by_availability(self, authenticated_client):
        client, _ = authenticated_client
        ProfessionalProfileFactory(license_status="verified", is_available=True)
        ProfessionalProfileFactory(license_status="verified", is_available=False)
        response = client.get(
            reverse("api:professional-list"),
            {"is_available": "true"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_filter_by_min_rating(self, authenticated_client):
        client, _ = authenticated_client
        ProfessionalProfileFactory(license_status="verified", average_rating=4.5)
        ProfessionalProfileFactory(license_status="verified", average_rating=3.0)
        response = client.get(
            reverse("api:professional-list"),
            {"min_rating": "4.0"},
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_unauthenticated_cannot_list(self, api_client):
        response = api_client.get(reverse("api:professional-list"))
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestProfessionalProfileDetail:
    def test_retrieve_verified_profile(self, authenticated_client):
        client, _ = authenticated_client
        profile = ProfessionalProfileFactory(license_status="verified")
        response = client.get(
            reverse("api:professional-detail", kwargs={"uuid": profile.uuid})
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["uuid"] == str(profile.uuid)
        assert "license_number" not in response.data  # Private field

    def test_cannot_retrieve_unverified_profile(self, authenticated_client):
        client, _ = authenticated_client
        profile = ProfessionalProfileFactory(license_status="pending_verification")
        response = client.get(
            reverse("api:professional-detail", kwargs={"uuid": profile.uuid})
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


@pytest.mark.django_db
class TestMyProfile:
    def test_get_own_profile(self, authenticated_client):
        client, user = authenticated_client
        profile = ProfessionalProfileFactory(user=user)
        response = client.get(reverse("api:professional-me"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["license_number"] == profile.license_number

    def test_create_own_profile(self, authenticated_client):
        client, user = authenticated_client
        data = {
            "license_number": "MN-RE-999999",
            "bio": "Experienced agent",
            "specializations": ["residential"],
        }
        response = client.post(reverse("api:professional-me"), data, format="json")
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["license_number"] == "MN-RE-999999"

    def test_update_own_profile(self, authenticated_client):
        client, user = authenticated_client
        ProfessionalProfileFactory(user=user)
        response = client.patch(
            reverse("api:professional-me"),
            {"bio": "Updated bio"},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["bio"] == "Updated bio"

    def test_returns_404_if_no_profile(self, authenticated_client):
        client, _ = authenticated_client
        response = client.get(reverse("api:professional-me"))
        assert response.status_code == status.HTTP_404_NOT_FOUND
```

**Step 6: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_views.py -v
```

Expected: FAIL

**Step 7: Write views**

```python
# backend/apps/professionals/api/views.py
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.professionals.api.serializers import (
    MetroSerializer,
    MyProfessionalProfileSerializer,
    ProfessionalProfileCreateSerializer,
    ProfessionalProfileSerializer,
    ServiceAreaSerializer,
)
from apps.professionals.models import (
    LicenseStatus,
    Metro,
    ProfessionalProfile,
    ServiceArea,
)


class ProfessionalProfileListView(generics.ListAPIView):
    """List verified professional profiles with search/filter."""

    serializer_class = ProfessionalProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["is_available", "specializations"]
    search_fields = ["user__first_name", "user__last_name", "bio"]
    ordering_fields = ["average_rating", "average_response_time"]
    ordering = ["-average_rating"]

    def get_queryset(self):
        queryset = ProfessionalProfile.objects.filter(
            license_status=LicenseStatus.VERIFIED,
        ).select_related("user").prefetch_related("service_areas__metro")

        service_area = self.request.query_params.get("service_area")
        if service_area:
            queryset = queryset.filter(service_areas__uuid=service_area)

        min_rating = self.request.query_params.get("min_rating")
        if min_rating:
            queryset = queryset.filter(average_rating__gte=min_rating)

        return queryset.distinct()


class ProfessionalProfileDetailView(generics.RetrieveAPIView):
    """Retrieve a single verified professional profile."""

    serializer_class = ProfessionalProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = "uuid"

    def get_queryset(self):
        return ProfessionalProfile.objects.filter(
            license_status=LicenseStatus.VERIFIED,
        ).select_related("user").prefetch_related("service_areas__metro")


class MyProfessionalProfileView(APIView):
    """Get, create, or update the authenticated user's own profile."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            profile = ProfessionalProfile.objects.select_related("user").prefetch_related(
                "service_areas__metro"
            ).get(user=request.user)
        except ProfessionalProfile.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        serializer = MyProfessionalProfileSerializer(profile)
        return Response(serializer.data)

    def post(self, request):
        serializer = ProfessionalProfileCreateSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        profile = serializer.save()
        return Response(
            MyProfessionalProfileSerializer(profile).data,
            status=status.HTTP_201_CREATED,
        )

    def patch(self, request):
        try:
            profile = ProfessionalProfile.objects.get(user=request.user)
        except ProfessionalProfile.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        serializer = ProfessionalProfileCreateSerializer(
            profile, data=request.data, partial=True, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        profile = serializer.save()
        return Response(MyProfessionalProfileSerializer(profile).data)


class ServiceAreaListView(generics.ListAPIView):
    serializer_class = ServiceAreaSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = ServiceArea.objects.select_related("metro").all()


class MetroListView(generics.ListAPIView):
    serializer_class = MetroSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Metro.objects.all()
```

**Step 8: Register routes in api_router.py**

Add to `backend/config/api_router.py`:

```python
from apps.professionals.api.views import (
    MetroListView,
    MyProfessionalProfileView,
    ProfessionalProfileDetailView,
    ProfessionalProfileListView,
    ServiceAreaListView,
)

# In the urlpatterns list:
urlpatterns += [
    path("professionals/me/", MyProfessionalProfileView.as_view(), name="professional-me"),
    path("professionals/", ProfessionalProfileListView.as_view(), name="professional-list"),
    path("professionals/<uuid:uuid>/", ProfessionalProfileDetailView.as_view(), name="professional-detail"),
    path("service-areas/", ServiceAreaListView.as_view(), name="servicearea-list"),
    path("metros/", MetroListView.as_view(), name="metro-list"),
]
```

Note: `professionals/me/` must come before `professionals/<uuid:uuid>/` to avoid UUID matching on "me".

**Step 9: Run all professionals tests**

```bash
docker compose run --rm django pytest apps/professionals/ -v
```

Expected: ALL PASS

**Step 10: Commit**

```bash
git add -A
git commit -m "feat(professionals): add API endpoints for profiles, service areas, and metros"
```

---

### Task 4: Verification Admin Actions

**Files:**
- Modify: `backend/apps/professionals/admin.py`
- Create: `backend/apps/professionals/tests/test_admin.py`
- Create: `backend/apps/professionals/tasks.py`

**Step 1: Write failing tests for admin verification action**

```python
# backend/apps/professionals/tests/test_admin.py
import pytest
from django.contrib.admin.sites import AdminSite
from django.utils import timezone

from apps.professionals.admin import ProfessionalProfileAdmin
from apps.professionals.models import ProfessionalProfile
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.users.tests.factories import UserFactory


@pytest.mark.django_db
class TestVerificationAdminAction:
    def test_verify_profile(self):
        profile = ProfessionalProfileFactory(license_status="pending_verification")
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = type("Request", (), {"user": admin_user})()

        admin.verify_profile(request, ProfessionalProfile.objects.filter(pk=profile.pk))

        profile.refresh_from_db()
        assert profile.license_status == "verified"
        assert profile.verified_by == admin_user
        assert profile.verified_at is not None

    def test_reject_profile(self):
        profile = ProfessionalProfileFactory(license_status="pending_verification")
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = type("Request", (), {"user": admin_user})()

        admin.reject_profile(request, ProfessionalProfile.objects.filter(pk=profile.pk))

        profile.refresh_from_db()
        assert profile.license_status == "rejected"
```

**Step 2: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_admin.py -v
```

Expected: FAIL

**Step 3: Add admin actions**

Update `backend/apps/professionals/admin.py` -- add these methods to `ProfessionalProfileAdmin`:

```python
from django.utils import timezone

@admin.register(ProfessionalProfile)
class ProfessionalProfileAdmin(admin.ModelAdmin):
    # ... existing fields ...
    actions = ["verify_profile", "reject_profile"]

    @admin.action(description="Verify selected profiles")
    def verify_profile(self, request, queryset):
        queryset.update(
            license_status="verified",
            verified_at=timezone.now(),
            verified_by=request.user,
        )

    @admin.action(description="Reject selected profiles")
    def reject_profile(self, request, queryset):
        queryset.update(license_status="rejected")
```

**Step 4: Run admin tests**

```bash
docker compose run --rm django pytest apps/professionals/tests/test_admin.py -v
```

Expected: PASS

**Step 5: Write verification email notification task**

```python
# backend/apps/professionals/tasks.py
from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail


@shared_task
def send_verification_status_email(profile_id: int, status: str) -> None:
    from apps.professionals.models import ProfessionalProfile

    profile = ProfessionalProfile.objects.select_related("user").get(pk=profile_id)

    if status == "verified":
        subject = "Your RealGig Profile Has Been Verified!"
        message = (
            f"Hi {profile.user.first_name},\n\n"
            "Your real estate license has been verified. "
            "You can now post gigs, accept invitations, and message other agents.\n\n"
            "Welcome to RealGig!"
        )
    elif status == "rejected":
        subject = "RealGig Verification Update"
        message = (
            f"Hi {profile.user.first_name},\n\n"
            "We were unable to verify your real estate license. "
            f"Reason: {profile.rejection_reason or 'Please contact support for details.'}\n\n"
            "If you believe this is an error, please contact support."
        )
    else:
        return

    send_mail(
        subject=subject,
        message=message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[profile.user.email],
    )
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat(professionals): add admin verification actions and email notifications"
```

---

## Phase 2: Gigs App

### Task 5: Gigs App -- Models

**Files:**
- Create: `backend/apps/gigs/` (new Django app)
- Create: `backend/apps/gigs/models.py`
- Create: `backend/apps/gigs/tests/factories.py`
- Create: `backend/apps/gigs/tests/test_models.py`
- Modify: `backend/config/settings/base.py`

**Step 1: Create the Django app**

```bash
cd backend && python manage.py startapp gigs apps/gigs && cd ..
```

**Step 2: Configure apps.py**

```python
# backend/apps/gigs/apps.py
from django.apps import AppConfig


class GigsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.gigs"
    verbose_name = "Gigs"
```

Add `"apps.gigs"` to `LOCAL_APPS` in `backend/config/settings/base.py`.

**Step 3: Write failing tests for Gig model**

```python
# backend/apps/gigs/tests/test_models.py
import pytest
from datetime import date, time
from decimal import Decimal

from apps.gigs.models import Gig, GigStatus, GigType
from apps.gigs.tests.factories import GigFactory, GigInvitationFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory, ServiceAreaFactory


@pytest.mark.django_db
class TestGig:
    def test_create_gig(self):
        profile = ProfessionalProfileFactory(license_status="verified")
        area = ServiceAreaFactory()
        gig = GigFactory(
            posted_by=profile,
            service_area=area,
            title="Showing at 123 Main St",
            budget_range_min=Decimal("50.00"),
            budget_range_max=Decimal("100.00"),
        )
        assert gig.title == "Showing at 123 Main St"
        assert gig.status == GigStatus.DRAFT
        assert gig.posted_by == profile
        assert gig.assigned_to is None

    def test_str_representation(self):
        gig = GigFactory(title="Open House at 456 Oak Ave")
        assert str(gig) == "Open House at 456 Oak Ave"

    def test_gig_status_transitions(self):
        gig = GigFactory(status=GigStatus.DRAFT)
        gig.status = GigStatus.POSTED
        gig.save()
        gig.refresh_from_db()
        assert gig.status == GigStatus.POSTED

    def test_gig_type_choices(self):
        gig = GigFactory(gig_type=GigType.SHOWING)
        assert gig.gig_type == "showing"


@pytest.mark.django_db
class TestGigInvitation:
    def test_create_invitation(self):
        gig = GigFactory(status=GigStatus.POSTED)
        agent = ProfessionalProfileFactory(license_status="verified")
        invitation = GigInvitationFactory(
            gig=gig,
            invited_agent=agent,
            proposed_rate=Decimal("75.00"),
            message="I'd be happy to help!",
        )
        assert invitation.gig == gig
        assert invitation.invited_agent == agent
        assert invitation.status == "pending"
        assert invitation.proposed_rate == Decimal("75.00")

    def test_str_representation(self):
        invitation = GigInvitationFactory()
        assert str(invitation).startswith("Invitation for")
```

**Step 4: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/gigs/tests/test_models.py -v
```

Expected: FAIL

**Step 5: Create factories**

```python
# backend/apps/gigs/tests/__init__.py
```

```python
# backend/apps/gigs/tests/factories.py
import factory
from datetime import date, time, timedelta
from decimal import Decimal

from apps.gigs.models import Gig, GigInvitation
from apps.professionals.tests.factories import ProfessionalProfileFactory, ServiceAreaFactory


class GigFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Gig

    posted_by = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    title = factory.Sequence(lambda n: f"Showing #{n}")
    description = factory.Faker("paragraph")
    location_address = factory.Faker("address")
    location_lat = factory.LazyFunction(lambda: Decimal("44.9778"))
    location_lng = factory.LazyFunction(lambda: Decimal("-93.2650"))
    service_area = factory.SubFactory(ServiceAreaFactory)
    scheduled_date = factory.LazyFunction(lambda: date.today() + timedelta(days=3))
    scheduled_time = factory.LazyFunction(lambda: time(14, 0))
    budget_range_min = factory.LazyFunction(lambda: Decimal("50.00"))
    budget_range_max = factory.LazyFunction(lambda: Decimal("150.00"))
    gig_type = "showing"


class GigInvitationFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = GigInvitation

    gig = factory.SubFactory(GigFactory, status="posted")
    invited_agent = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    proposed_rate = factory.LazyFunction(lambda: Decimal("75.00"))
    message = factory.Faker("sentence")
```

**Step 6: Write the Gig and GigInvitation models**

```python
# backend/apps/gigs/models.py
from decimal import Decimal

from django.db import models

from apps.shared.models import BaseModel


class GigStatus(models.TextChoices):
    DRAFT = "draft", "Draft"
    POSTED = "posted", "Posted"
    INVITED = "invited", "Invited"
    NEGOTIATING = "negotiating", "Negotiating"
    ACCEPTED = "accepted", "Accepted"
    IN_PROGRESS = "in_progress", "In Progress"
    COMPLETED = "completed", "Completed"
    CANCELLED = "cancelled", "Cancelled"
    DISPUTED = "disputed", "Disputed"


class GigType(models.TextChoices):
    SHOWING = "showing", "Showing"
    OPEN_HOUSE = "open_house", "Open House"
    INSPECTION = "inspection_accompaniment", "Inspection Accompaniment"
    OTHER = "other", "Other"


class InvitationStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    ACCEPTED = "accepted", "Accepted"
    DECLINED = "declined", "Declined"
    WITHDRAWN = "withdrawn", "Withdrawn"


class Gig(BaseModel):
    posted_by = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="posted_gigs",
    )
    assigned_to = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_gigs",
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    location_address = models.CharField(max_length=500)
    location_lat = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    location_lng = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    service_area = models.ForeignKey(
        "professionals.ServiceArea",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="gigs",
    )
    scheduled_date = models.DateField()
    scheduled_time = models.TimeField()
    budget_range_min = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    budget_range_max = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    agreed_price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    status = models.CharField(
        max_length=20,
        choices=GigStatus.choices,
        default=GigStatus.DRAFT,
    )
    gig_type = models.CharField(
        max_length=30,
        choices=GigType.choices,
        default=GigType.SHOWING,
    )

    class Meta:
        ordering = ["-created"]
        indexes = [
            models.Index(fields=["status"]),
            models.Index(fields=["posted_by", "status"]),
            models.Index(fields=["assigned_to", "status"]),
            models.Index(fields=["scheduled_date"]),
            models.Index(fields=["service_area"]),
        ]

    def __str__(self) -> str:
        return self.title


class GigInvitation(BaseModel):
    gig = models.ForeignKey(
        Gig,
        on_delete=models.CASCADE,
        related_name="invitations",
    )
    invited_agent = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="gig_invitations",
    )
    proposed_rate = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    message = models.TextField(blank=True)
    status = models.CharField(
        max_length=20,
        choices=InvitationStatus.choices,
        default=InvitationStatus.PENDING,
    )

    class Meta:
        ordering = ["-created"]
        unique_together = ["gig", "invited_agent"]

    def __str__(self) -> str:
        return f"Invitation for {self.gig.title} to {self.invited_agent}"
```

**Step 7: Create and run migrations**

```bash
docker compose run --rm django python manage.py makemigrations gigs
docker compose run --rm django python manage.py migrate
```

**Step 8: Run all gig model tests**

```bash
docker compose run --rm django pytest apps/gigs/tests/test_models.py -v
```

Expected: ALL PASS

**Step 9: Write admin**

```python
# backend/apps/gigs/admin.py
from django.contrib import admin

from apps.gigs.models import Gig, GigInvitation


@admin.register(Gig)
class GigAdmin(admin.ModelAdmin):
    list_display = ["title", "posted_by", "assigned_to", "status", "gig_type", "scheduled_date"]
    list_filter = ["status", "gig_type"]
    search_fields = ["title", "description", "location_address"]
    raw_id_fields = ["posted_by", "assigned_to", "service_area"]


@admin.register(GigInvitation)
class GigInvitationAdmin(admin.ModelAdmin):
    list_display = ["gig", "invited_agent", "proposed_rate", "status"]
    list_filter = ["status"]
    raw_id_fields = ["gig", "invited_agent"]
```

**Step 10: Commit**

```bash
git add -A
git commit -m "feat(gigs): add Gig and GigInvitation models with tests"
```

---

### Task 6: Gigs App -- API & Lifecycle

**Files:**
- Create: `backend/apps/gigs/api/__init__.py`
- Create: `backend/apps/gigs/api/serializers.py`
- Create: `backend/apps/gigs/api/views.py`
- Create: `backend/apps/gigs/api/permissions.py`
- Create: `backend/apps/gigs/tests/test_views.py`
- Modify: `backend/config/api_router.py`

**Step 1: Write failing tests for gig API**

```python
# backend/apps/gigs/tests/test_views.py
import pytest
from datetime import date, time, timedelta
from decimal import Decimal

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.gigs.models import Gig, GigStatus, GigInvitation
from apps.gigs.tests.factories import GigFactory, GigInvitationFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory, ServiceAreaFactory
from apps.users.tests.factories import UserFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def verified_agent(api_client):
    """Returns (client, user, profile) for a verified agent."""
    user = UserFactory(is_email_verified=True)
    profile = ProfessionalProfileFactory(user=user, license_status="verified")
    api_client.force_authenticate(user=user)
    return api_client, user, profile


@pytest.mark.django_db
class TestGigCreate:
    def test_create_gig(self, verified_agent):
        client, user, profile = verified_agent
        area = ServiceAreaFactory()
        data = {
            "title": "Showing at 123 Main St",
            "description": "3BR/2BA, client is pre-approved",
            "location_address": "123 Main St, Minneapolis, MN",
            "service_area_uuid": str(area.uuid),
            "scheduled_date": str(date.today() + timedelta(days=3)),
            "scheduled_time": "14:00",
            "budget_range_min": "50.00",
            "budget_range_max": "100.00",
            "gig_type": "showing",
        }
        response = client.post(reverse("api:gig-list"), data, format="json")
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["title"] == "Showing at 123 Main St"
        assert response.data["status"] == "draft"
        assert response.data["posted_by"]["uuid"] == str(profile.uuid)

    def test_unverified_cannot_create_gig(self, api_client):
        user = UserFactory(is_email_verified=True)
        ProfessionalProfileFactory(user=user, license_status="pending_verification")
        api_client.force_authenticate(user=user)
        data = {
            "title": "Test",
            "location_address": "123 Main St",
            "scheduled_date": str(date.today() + timedelta(days=3)),
            "scheduled_time": "14:00",
            "gig_type": "showing",
        }
        response = api_client.post(reverse("api:gig-list"), data, format="json")
        assert response.status_code == status.HTTP_403_FORBIDDEN


@pytest.mark.django_db
class TestGigList:
    def test_list_own_gigs(self, verified_agent):
        client, user, profile = verified_agent
        GigFactory(posted_by=profile)
        GigFactory()  # someone else's gig
        response = client.get(reverse("api:gig-list"))
        assert response.status_code == status.HTTP_200_OK
        # Should see own gigs + posted gigs visible to all
        assert response.data["count"] >= 1

    def test_list_posted_gigs_marketplace(self, verified_agent):
        client, user, profile = verified_agent
        GigFactory(status=GigStatus.POSTED)
        GigFactory(status=GigStatus.DRAFT)  # not visible
        response = client.get(reverse("api:gig-list"), {"marketplace": "true"})
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1


@pytest.mark.django_db
class TestGigStatusTransition:
    def test_post_gig(self, verified_agent):
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.DRAFT)
        response = client.post(
            reverse("api:gig-transition", kwargs={"uuid": gig.uuid}),
            {"status": "posted"},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["status"] == "posted"

    def test_cancel_gig(self, verified_agent):
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.POSTED)
        response = client.post(
            reverse("api:gig-transition", kwargs={"uuid": gig.uuid}),
            {"status": "cancelled"},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["status"] == "cancelled"

    def test_cannot_transition_others_gig(self, verified_agent):
        client, _, _ = verified_agent
        gig = GigFactory(status=GigStatus.DRAFT)  # another agent's gig
        response = client.post(
            reverse("api:gig-transition", kwargs={"uuid": gig.uuid}),
            {"status": "posted"},
            format="json",
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


@pytest.mark.django_db
class TestGigInvitations:
    def test_create_invitation(self, verified_agent):
        client, user, profile = verified_agent
        gig = GigFactory(posted_by=profile, status=GigStatus.POSTED)
        other_agent = ProfessionalProfileFactory(license_status="verified")
        data = {
            "invited_agent_uuid": str(other_agent.uuid),
            "message": "Can you cover this showing?",
        }
        response = client.post(
            reverse("api:gig-invitation-list", kwargs={"gig_uuid": gig.uuid}),
            data,
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["status"] == "pending"

    def test_respond_to_invitation(self, api_client):
        agent_user = UserFactory(is_email_verified=True)
        agent_profile = ProfessionalProfileFactory(user=agent_user, license_status="verified")
        invitation = GigInvitationFactory(invited_agent=agent_profile)
        api_client.force_authenticate(user=agent_user)

        response = api_client.patch(
            reverse("api:gig-invitation-detail", kwargs={
                "gig_uuid": invitation.gig.uuid,
                "uuid": invitation.uuid,
            }),
            {"status": "accepted", "proposed_rate": "85.00"},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert response.data["status"] == "accepted"

    def test_cannot_invite_to_others_gig(self, verified_agent):
        client, _, _ = verified_agent
        gig = GigFactory(status=GigStatus.POSTED)  # not our gig
        other_agent = ProfessionalProfileFactory(license_status="verified")
        data = {"invited_agent_uuid": str(other_agent.uuid)}
        response = client.post(
            reverse("api:gig-invitation-list", kwargs={"gig_uuid": gig.uuid}),
            data,
            format="json",
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN
```

**Step 2: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/gigs/tests/test_views.py -v
```

Expected: FAIL

**Step 3: Write permissions**

```python
# backend/apps/gigs/api/permissions.py
from rest_framework.permissions import BasePermission

from apps.professionals.models import LicenseStatus


class IsVerifiedProfessional(BasePermission):
    """Only verified professionals can access this view."""

    message = "You must have a verified professional profile to perform this action."

    def has_permission(self, request, view) -> bool:
        if not request.user.is_authenticated:
            return False
        profile = getattr(request.user, "professional_profile", None)
        if profile is None:
            return False
        return profile.license_status == LicenseStatus.VERIFIED
```

**Step 4: Write serializers**

```python
# backend/apps/gigs/api/__init__.py
```

```python
# backend/apps/gigs/api/serializers.py
from rest_framework import serializers

from apps.gigs.models import Gig, GigInvitation, GigStatus
from apps.professionals.api.serializers import ProfessionalProfileSerializer
from apps.professionals.models import ProfessionalProfile, ServiceArea


class GigSerializer(serializers.ModelSerializer):
    posted_by = ProfessionalProfileSerializer(read_only=True)
    assigned_to = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Gig
        fields = [
            "uuid", "title", "description", "location_address",
            "location_lat", "location_lng", "scheduled_date", "scheduled_time",
            "budget_range_min", "budget_range_max", "agreed_price",
            "status", "gig_type", "posted_by", "assigned_to",
            "created", "modified",
        ]
        read_only_fields = ["uuid", "status", "posted_by", "assigned_to", "agreed_price", "created", "modified"]


class GigCreateSerializer(serializers.ModelSerializer):
    service_area_uuid = serializers.UUIDField(write_only=True, required=False)

    class Meta:
        model = Gig
        fields = [
            "title", "description", "location_address",
            "location_lat", "location_lng", "service_area_uuid",
            "scheduled_date", "scheduled_time",
            "budget_range_min", "budget_range_max", "gig_type",
        ]

    def create(self, validated_data: dict) -> Gig:
        service_area_uuid = validated_data.pop("service_area_uuid", None)
        user = self.context["request"].user
        profile = user.professional_profile

        service_area = None
        if service_area_uuid:
            service_area = ServiceArea.objects.filter(uuid=service_area_uuid).first()

        return Gig.objects.create(
            posted_by=profile,
            service_area=service_area,
            **validated_data,
        )


class GigStatusTransitionSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=GigStatus.choices)

    # Valid transitions: from_status -> [allowed to_statuses]
    VALID_TRANSITIONS = {
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
                f"Allowed: {[s.value for s in allowed]}"
            )
        return value


class GigInvitationSerializer(serializers.ModelSerializer):
    invited_agent = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = GigInvitation
        fields = [
            "uuid", "invited_agent", "proposed_rate",
            "message", "status", "created",
        ]
        read_only_fields = ["uuid", "invited_agent", "created"]


class GigInvitationCreateSerializer(serializers.Serializer):
    invited_agent_uuid = serializers.UUIDField()
    message = serializers.CharField(required=False, default="")

    def validate_invited_agent_uuid(self, value):
        try:
            agent = ProfessionalProfile.objects.get(uuid=value, license_status="verified")
        except ProfessionalProfile.DoesNotExist:
            raise serializers.ValidationError("Agent not found or not verified.")
        return agent

    def create(self, validated_data: dict) -> GigInvitation:
        return GigInvitation.objects.create(
            gig=self.context["gig"],
            invited_agent=validated_data["invited_agent_uuid"],
            message=validated_data.get("message", ""),
        )
```

**Step 5: Write views**

```python
# backend/apps/gigs/api/views.py
from django.db.models import Q
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.gigs.api.serializers import (
    GigCreateSerializer,
    GigInvitationCreateSerializer,
    GigInvitationSerializer,
    GigSerializer,
    GigStatusTransitionSerializer,
)
from apps.gigs.models import Gig, GigInvitation, GigStatus


class GigListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return GigCreateSerializer
        return GigSerializer

    def get_queryset(self):
        profile = self.request.user.professional_profile
        marketplace = self.request.query_params.get("marketplace")

        if marketplace:
            # Show all posted gigs (marketplace view)
            return Gig.objects.filter(
                status=GigStatus.POSTED,
            ).select_related("posted_by__user", "assigned_to__user")
        else:
            # Show own gigs (posted + assigned)
            return Gig.objects.filter(
                Q(posted_by=profile) | Q(assigned_to=profile)
            ).select_related("posted_by__user", "assigned_to__user")

    def perform_create(self, serializer):
        serializer.save()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        gig = serializer.save()
        return Response(
            GigSerializer(gig).data,
            status=status.HTTP_201_CREATED,
        )


class GigDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = GigSerializer
    permission_classes = [IsVerifiedProfessional]
    lookup_field = "uuid"

    def get_queryset(self):
        return Gig.objects.select_related("posted_by__user", "assigned_to__user")


class GigStatusTransitionView(APIView):
    permission_classes = [IsVerifiedProfessional]

    def post(self, request, uuid):
        profile = request.user.professional_profile
        try:
            gig = Gig.objects.get(uuid=uuid, posted_by=profile)
        except Gig.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = GigStatusTransitionSerializer(
            data=request.data, context={"gig": gig}
        )
        serializer.is_valid(raise_exception=True)
        gig.status = serializer.validated_data["status"]
        gig.save()
        return Response(GigSerializer(gig).data)


class GigInvitationListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return GigInvitationCreateSerializer
        return GigInvitationSerializer

    def get_gig(self):
        return Gig.objects.get(uuid=self.kwargs["gig_uuid"])

    def get_queryset(self):
        return GigInvitation.objects.filter(
            gig__uuid=self.kwargs["gig_uuid"]
        ).select_related("invited_agent__user")

    def create(self, request, *args, **kwargs):
        gig = self.get_gig()
        profile = request.user.professional_profile

        # Only gig poster can create invitations
        if gig.posted_by != profile:
            return Response(
                {"detail": "Only the gig poster can create invitations."},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = GigInvitationCreateSerializer(
            data=request.data, context={"gig": gig}
        )
        serializer.is_valid(raise_exception=True)
        invitation = serializer.save()
        return Response(
            GigInvitationSerializer(invitation).data,
            status=status.HTTP_201_CREATED,
        )


class GigInvitationDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = GigInvitationSerializer
    permission_classes = [IsVerifiedProfessional]
    lookup_field = "uuid"

    def get_queryset(self):
        return GigInvitation.objects.filter(
            gig__uuid=self.kwargs["gig_uuid"]
        ).select_related("invited_agent__user")
```

**Step 6: Register routes**

Add to `backend/config/api_router.py`:

```python
from apps.gigs.api.views import (
    GigDetailView,
    GigInvitationDetailView,
    GigInvitationListCreateView,
    GigListCreateView,
    GigStatusTransitionView,
)

urlpatterns += [
    path("gigs/", GigListCreateView.as_view(), name="gig-list"),
    path("gigs/<uuid:uuid>/", GigDetailView.as_view(), name="gig-detail"),
    path("gigs/<uuid:uuid>/transition/", GigStatusTransitionView.as_view(), name="gig-transition"),
    path("gigs/<uuid:gig_uuid>/invitations/", GigInvitationListCreateView.as_view(), name="gig-invitation-list"),
    path("gigs/<uuid:gig_uuid>/invitations/<uuid:uuid>/", GigInvitationDetailView.as_view(), name="gig-invitation-detail"),
]
```

**Step 7: Run all gig tests**

```bash
docker compose run --rm django pytest apps/gigs/ -v
```

Expected: ALL PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat(gigs): add gig API with lifecycle transitions and invitations"
```

---

## Phase 3: Messaging

### Task 7: Messaging App

**Files:**
- Create: `backend/apps/messaging/` (new Django app)
- Create: `backend/apps/messaging/models.py`
- Create: `backend/apps/messaging/api/serializers.py`
- Create: `backend/apps/messaging/api/views.py`
- Create: `backend/apps/messaging/tests/`
- Modify: `backend/config/settings/base.py`
- Modify: `backend/config/api_router.py`

**Step 1: Create the Django app**

```bash
cd backend && python manage.py startapp messaging apps/messaging && cd ..
```

Add `"apps.messaging"` to `LOCAL_APPS`.

**Step 2: Write failing tests for models**

```python
# backend/apps/messaging/tests/__init__.py
```

```python
# backend/apps/messaging/tests/factories.py
import factory
from apps.messaging.models import Conversation, Message
from apps.professionals.tests.factories import ProfessionalProfileFactory


class ConversationFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Conversation

    participant_1 = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    participant_2 = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")


class MessageFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Message

    conversation = factory.SubFactory(ConversationFactory)
    sender = factory.LazyAttribute(lambda obj: obj.conversation.participant_1)
    body = factory.Faker("sentence")
```

```python
# backend/apps/messaging/tests/test_models.py
import pytest
from apps.messaging.tests.factories import ConversationFactory, MessageFactory


@pytest.mark.django_db
class TestConversation:
    def test_create_conversation(self):
        convo = ConversationFactory()
        assert convo.participant_1 != convo.participant_2
        assert convo.gig is None

    def test_str_representation(self):
        convo = ConversationFactory()
        assert str(convo).startswith("Conversation between")


@pytest.mark.django_db
class TestMessage:
    def test_create_message(self):
        msg = MessageFactory(body="Hello!")
        assert msg.body == "Hello!"
        assert msg.read_at is None

    def test_mark_as_read(self):
        msg = MessageFactory()
        assert msg.read_at is None
        msg.mark_as_read()
        assert msg.read_at is not None
```

**Step 3: Run tests to verify they fail**

```bash
docker compose run --rm django pytest apps/messaging/tests/ -v
```

Expected: FAIL

**Step 4: Write models**

```python
# backend/apps/messaging/models.py
from django.db import models
from django.utils import timezone

from apps.shared.models import BaseModel


class Conversation(BaseModel):
    participant_1 = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="conversations_as_p1",
    )
    participant_2 = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="conversations_as_p2",
    )
    gig = models.ForeignKey(
        "gigs.Gig",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="conversations",
    )

    class Meta:
        ordering = ["-modified"]
        unique_together = ["participant_1", "participant_2", "gig"]

    def __str__(self) -> str:
        return f"Conversation between {self.participant_1} and {self.participant_2}"


class Message(BaseModel):
    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.CASCADE,
        related_name="messages",
    )
    sender = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="sent_messages",
    )
    body = models.TextField()
    read_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["created"]

    def __str__(self) -> str:
        return f"Message from {self.sender} at {self.created}"

    def mark_as_read(self) -> None:
        if self.read_at is None:
            self.read_at = timezone.now()
            self.save(update_fields=["read_at"])
```

**Step 5: Create migrations, run tests**

```bash
docker compose run --rm django python manage.py makemigrations messaging
docker compose run --rm django python manage.py migrate
docker compose run --rm django pytest apps/messaging/tests/ -v
```

Expected: ALL PASS

**Step 6: Write API (serializers + views + tests)**

Follow the same TDD pattern as Tasks 3 and 6. Key endpoints:

- `GET /api/conversations/` -- list conversations for authenticated user
- `POST /api/conversations/` -- create conversation (with participant_uuid, optional gig_uuid)
- `GET /api/conversations/:uuid/messages/` -- list messages in conversation
- `POST /api/conversations/:uuid/messages/` -- send message

Permission: `IsVerifiedProfessional` + only conversation participants can access.

```python
# backend/apps/messaging/api/serializers.py
from rest_framework import serializers
from apps.messaging.models import Conversation, Message
from apps.professionals.api.serializers import ProfessionalProfileSerializer


class MessageSerializer(serializers.ModelSerializer):
    sender = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ["uuid", "sender", "body", "read_at", "created"]
        read_only_fields = ["uuid", "sender", "read_at", "created"]


class MessageCreateSerializer(serializers.Serializer):
    body = serializers.CharField()


class ConversationSerializer(serializers.ModelSerializer):
    participant_1 = ProfessionalProfileSerializer(read_only=True)
    participant_2 = ProfessionalProfileSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            "uuid", "participant_1", "participant_2",
            "gig", "last_message", "unread_count", "modified",
        ]

    def get_last_message(self, obj) -> dict | None:
        msg = obj.messages.order_by("-created").first()
        if msg:
            return MessageSerializer(msg).data
        return None

    def get_unread_count(self, obj) -> int:
        user = self.context["request"].user
        profile = user.professional_profile
        return obj.messages.filter(read_at__isnull=True).exclude(sender=profile).count()


class ConversationCreateSerializer(serializers.Serializer):
    participant_uuid = serializers.UUIDField()
    gig_uuid = serializers.UUIDField(required=False, allow_null=True, default=None)
```

```python
# backend/apps/messaging/api/views.py
from django.db.models import Q
from rest_framework import generics, permissions, status
from rest_framework.response import Response

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.gigs.models import Gig
from apps.messaging.api.serializers import (
    ConversationCreateSerializer,
    ConversationSerializer,
    MessageCreateSerializer,
    MessageSerializer,
)
from apps.messaging.models import Conversation, Message
from apps.professionals.models import ProfessionalProfile


class ConversationListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return ConversationCreateSerializer
        return ConversationSerializer

    def get_queryset(self):
        profile = self.request.user.professional_profile
        return Conversation.objects.filter(
            Q(participant_1=profile) | Q(participant_2=profile)
        ).select_related("participant_1__user", "participant_2__user").prefetch_related("messages")

    def create(self, request, *args, **kwargs):
        serializer = ConversationCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        profile = request.user.professional_profile
        other = ProfessionalProfile.objects.get(uuid=serializer.validated_data["participant_uuid"])
        gig_uuid = serializer.validated_data.get("gig_uuid")
        gig = Gig.objects.filter(uuid=gig_uuid).first() if gig_uuid else None

        # Check for existing conversation
        existing = Conversation.objects.filter(
            Q(participant_1=profile, participant_2=other) |
            Q(participant_1=other, participant_2=profile),
            gig=gig,
        ).first()

        if existing:
            return Response(
                ConversationSerializer(existing, context={"request": request}).data,
            )

        convo = Conversation.objects.create(
            participant_1=profile,
            participant_2=other,
            gig=gig,
        )
        return Response(
            ConversationSerializer(convo, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


class MessageListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsVerifiedProfessional]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return MessageCreateSerializer
        return MessageSerializer

    def get_queryset(self):
        profile = self.request.user.professional_profile
        return Message.objects.filter(
            conversation__uuid=self.kwargs["conversation_uuid"],
        ).filter(
            Q(conversation__participant_1=profile) | Q(conversation__participant_2=profile)
        ).select_related("sender__user")

    def create(self, request, *args, **kwargs):
        profile = request.user.professional_profile
        try:
            convo = Conversation.objects.get(
                uuid=self.kwargs["conversation_uuid"],
            )
        except Conversation.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        # Verify participant
        if profile not in (convo.participant_1, convo.participant_2):
            return Response(status=status.HTTP_403_FORBIDDEN)

        serializer = MessageCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        msg = Message.objects.create(
            conversation=convo,
            sender=profile,
            body=serializer.validated_data["body"],
        )
        # Update conversation modified timestamp
        convo.save()

        return Response(
            MessageSerializer(msg).data,
            status=status.HTTP_201_CREATED,
        )
```

Register routes in `backend/config/api_router.py`:

```python
from apps.messaging.api.views import ConversationListCreateView, MessageListCreateView

urlpatterns += [
    path("conversations/", ConversationListCreateView.as_view(), name="conversation-list"),
    path("conversations/<uuid:conversation_uuid>/messages/", MessageListCreateView.as_view(), name="message-list"),
]
```

**Step 7: Run all messaging tests**

```bash
docker compose run --rm django pytest apps/messaging/ -v
```

Expected: ALL PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat(messaging): add conversation and message models with API"
```

---

## Phase 4: Reviews

### Task 8: Reviews App

**Files:**
- Create: `backend/apps/reviews/` (new Django app)
- Create: `backend/apps/reviews/models.py`
- Create: `backend/apps/reviews/api/serializers.py`
- Create: `backend/apps/reviews/api/views.py`
- Create: `backend/apps/reviews/tests/`
- Modify: `backend/config/settings/base.py`
- Modify: `backend/config/api_router.py`

**Step 1: Create the Django app**

```bash
cd backend && python manage.py startapp reviews apps/reviews && cd ..
```

Add `"apps.reviews"` to `LOCAL_APPS`.

**Step 2: Write failing tests**

```python
# backend/apps/reviews/tests/__init__.py
```

```python
# backend/apps/reviews/tests/factories.py
import factory
from apps.reviews.models import Review
from apps.gigs.tests.factories import GigFactory
from apps.professionals.tests.factories import ProfessionalProfileFactory


class ReviewFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Review

    gig = factory.SubFactory(GigFactory, status="completed")
    reviewer = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    reviewee = factory.SubFactory(ProfessionalProfileFactory, license_status="verified")
    rating = 5
    comment = factory.Faker("sentence")
    is_from_poster = True
```

```python
# backend/apps/reviews/tests/test_models.py
import pytest
from decimal import Decimal
from apps.reviews.tests.factories import ReviewFactory
from apps.reviews.models import Review
from apps.gigs.tests.factories import GigFactory
from apps.gigs.models import GigStatus
from apps.professionals.tests.factories import ProfessionalProfileFactory


@pytest.mark.django_db
class TestReview:
    def test_create_review(self):
        review = ReviewFactory(rating=4, comment="Great work!")
        assert review.rating == 4
        assert review.comment == "Great work!"

    def test_rating_range(self):
        review = ReviewFactory(rating=5)
        assert 1 <= review.rating <= 5

    def test_one_review_per_direction_per_gig(self):
        """Can't review the same person twice for the same gig."""
        gig = GigFactory(status=GigStatus.COMPLETED)
        reviewer = ProfessionalProfileFactory(license_status="verified")
        reviewee = ProfessionalProfileFactory(license_status="verified")
        ReviewFactory(gig=gig, reviewer=reviewer, reviewee=reviewee)
        with pytest.raises(Exception):  # IntegrityError
            ReviewFactory(gig=gig, reviewer=reviewer, reviewee=reviewee)

    def test_update_average_rating(self):
        """Creating reviews should update the reviewee's average_rating."""
        agent = ProfessionalProfileFactory(license_status="verified")
        ReviewFactory(reviewee=agent, rating=4)
        ReviewFactory(reviewee=agent, rating=5)
        agent.refresh_from_db()
        assert agent.average_rating == Decimal("4.50")
```

**Step 3: Write model**

```python
# backend/apps/reviews/models.py
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.db.models import Avg

from apps.shared.models import BaseModel


class Review(BaseModel):
    gig = models.ForeignKey(
        "gigs.Gig",
        on_delete=models.CASCADE,
        related_name="reviews",
    )
    reviewer = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="reviews_given",
    )
    reviewee = models.ForeignKey(
        "professionals.ProfessionalProfile",
        on_delete=models.CASCADE,
        related_name="reviews_received",
    )
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
    )
    comment = models.TextField(blank=True)
    is_from_poster = models.BooleanField()

    class Meta:
        ordering = ["-created"]
        unique_together = ["gig", "reviewer", "reviewee"]

    def __str__(self) -> str:
        return f"Review by {self.reviewer} for {self.reviewee} ({self.rating}/5)"

    def save(self, *args, **kwargs) -> None:
        super().save(*args, **kwargs)
        self._update_reviewee_rating()

    def _update_reviewee_rating(self) -> None:
        avg = Review.objects.filter(reviewee=self.reviewee).aggregate(
            avg_rating=Avg("rating")
        )["avg_rating"]
        if avg is not None:
            from apps.professionals.models import ProfessionalProfile
            ProfessionalProfile.objects.filter(pk=self.reviewee_id).update(
                average_rating=round(avg, 2)
            )
```

**Step 4: Create migrations, run tests**

```bash
docker compose run --rm django python manage.py makemigrations reviews
docker compose run --rm django python manage.py migrate
docker compose run --rm django pytest apps/reviews/ -v
```

Expected: ALL PASS

**Step 5: Write API (serializers + views)**

Key endpoints:
- `POST /api/reviews/` -- create a review (only for completed gigs you participated in)
- `GET /api/professionals/:uuid/reviews/` -- list reviews for an agent

```python
# backend/apps/reviews/api/__init__.py
```

```python
# backend/apps/reviews/api/serializers.py
from rest_framework import serializers
from apps.reviews.models import Review
from apps.professionals.api.serializers import ProfessionalProfileSerializer


class ReviewSerializer(serializers.ModelSerializer):
    reviewer = ProfessionalProfileSerializer(read_only=True)

    class Meta:
        model = Review
        fields = ["uuid", "reviewer", "rating", "comment", "is_from_poster", "created"]
        read_only_fields = ["uuid", "reviewer", "is_from_poster", "created"]


class ReviewCreateSerializer(serializers.Serializer):
    gig_uuid = serializers.UUIDField()
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, default="")
```

```python
# backend/apps/reviews/api/views.py
from rest_framework import generics, status
from rest_framework.response import Response

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.gigs.models import Gig, GigStatus
from apps.professionals.models import ProfessionalProfile
from apps.reviews.api.serializers import ReviewCreateSerializer, ReviewSerializer
from apps.reviews.models import Review


class ReviewCreateView(generics.CreateAPIView):
    permission_classes = [IsVerifiedProfessional]
    serializer_class = ReviewCreateSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        profile = request.user.professional_profile
        gig = Gig.objects.get(
            uuid=serializer.validated_data["gig_uuid"],
            status=GigStatus.COMPLETED,
        )

        # Determine reviewer/reviewee
        if gig.posted_by == profile:
            reviewee = gig.assigned_to
            is_from_poster = True
        elif gig.assigned_to == profile:
            reviewee = gig.posted_by
            is_from_poster = False
        else:
            return Response(
                {"detail": "You are not a participant of this gig."},
                status=status.HTTP_403_FORBIDDEN,
            )

        review = Review.objects.create(
            gig=gig,
            reviewer=profile,
            reviewee=reviewee,
            rating=serializer.validated_data["rating"],
            comment=serializer.validated_data.get("comment", ""),
            is_from_poster=is_from_poster,
        )
        return Response(ReviewSerializer(review).data, status=status.HTTP_201_CREATED)


class ProfessionalReviewListView(generics.ListAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [IsVerifiedProfessional]

    def get_queryset(self):
        return Review.objects.filter(
            reviewee__uuid=self.kwargs["uuid"]
        ).select_related("reviewer__user")
```

Register routes:

```python
from apps.reviews.api.views import ReviewCreateView, ProfessionalReviewListView

urlpatterns += [
    path("reviews/", ReviewCreateView.as_view(), name="review-create"),
    path("professionals/<uuid:uuid>/reviews/", ProfessionalReviewListView.as_view(), name="professional-reviews"),
]
```

**Step 6: Run all tests, commit**

```bash
docker compose run --rm django pytest apps/reviews/ -v
git add -A
git commit -m "feat(reviews): add review model with rating aggregation and API"
```

---

## Phase 5: Payments

### Task 9: Payments App (Stripe Connect)

**Files:**
- Create: `backend/apps/payments/` (new Django app)
- Create: `backend/apps/payments/models.py`
- Create: `backend/apps/payments/api/views.py`
- Create: `backend/apps/payments/services.py` (Stripe integration)
- Create: `backend/apps/payments/tests/`
- Modify: `backend/config/settings/base.py` (add stripe settings)
- Modify: `backend/pyproject.toml` (add stripe dependency)

**Step 1: Add stripe dependency**

Add `stripe>=8.0.0` to `[project.dependencies]` in `backend/pyproject.toml`.

```bash
docker compose build django
```

**Step 2: Create the Django app**

```bash
cd backend && python manage.py startapp payments apps/payments && cd ..
```

Add `"apps.payments"` to `LOCAL_APPS`.

Add to `backend/config/settings/base.py`:

```python
# Stripe
STRIPE_SECRET_KEY = env("STRIPE_SECRET_KEY", default="sk_test_placeholder")
STRIPE_PUBLISHABLE_KEY = env("STRIPE_PUBLISHABLE_KEY", default="pk_test_placeholder")
STRIPE_WEBHOOK_SECRET = env("STRIPE_WEBHOOK_SECRET", default="whsec_placeholder")
STRIPE_PLATFORM_FEE_PERCENT = env.float("STRIPE_PLATFORM_FEE_PERCENT", default=0.10)
```

**Step 3: Write Payment model**

```python
# backend/apps/payments/models.py
from django.db import models
from apps.shared.models import BaseModel


class PaymentStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    CAPTURED = "captured", "Captured"
    RELEASED = "released", "Released"
    REFUNDED = "refunded", "Refunded"
    FAILED = "failed", "Failed"


class Payment(BaseModel):
    gig = models.OneToOneField(
        "gigs.Gig",
        on_delete=models.CASCADE,
        related_name="payment",
    )
    stripe_payment_intent_id = models.CharField(max_length=255, blank=True, default="")
    stripe_transfer_id = models.CharField(max_length=255, blank=True, default="")
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    platform_fee = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=20,
        choices=PaymentStatus.choices,
        default=PaymentStatus.PENDING,
    )

    class Meta:
        ordering = ["-created"]

    def __str__(self) -> str:
        return f"Payment for {self.gig.title} - ${self.amount} ({self.status})"
```

**Step 4: Write Stripe service layer**

```python
# backend/apps/payments/services.py
from decimal import Decimal

import stripe
from django.conf import settings

stripe.api_key = settings.STRIPE_SECRET_KEY


def create_connect_account_link(profile) -> str:
    """Create a Stripe Connect onboarding link for an agent."""
    if not profile.stripe_connect_account_id:
        account = stripe.Account.create(
            type="express",
            email=profile.user.email,
            metadata={"profile_uuid": str(profile.uuid)},
        )
        profile.stripe_connect_account_id = account.id
        profile.save(update_fields=["stripe_connect_account_id"])

    link = stripe.AccountLink.create(
        account=profile.stripe_connect_account_id,
        refresh_url=f"{settings.FRONTEND_URL}/settings/stripe/refresh",
        return_url=f"{settings.FRONTEND_URL}/settings/stripe/complete",
        type="account_onboarding",
    )
    return link.url


def create_payment_intent(gig) -> stripe.PaymentIntent:
    """Create a PaymentIntent when a gig is accepted."""
    from apps.payments.models import Payment

    amount_cents = int(gig.agreed_price * 100)
    fee_percent = Decimal(str(settings.STRIPE_PLATFORM_FEE_PERCENT))
    platform_fee = gig.agreed_price * fee_percent
    fee_cents = int(platform_fee * 100)

    intent = stripe.PaymentIntent.create(
        amount=amount_cents,
        currency="usd",
        payment_method_types=["card"],
        application_fee_amount=fee_cents,
        transfer_data={
            "destination": gig.assigned_to.stripe_connect_account_id,
        },
        metadata={
            "gig_uuid": str(gig.uuid),
        },
    )

    Payment.objects.create(
        gig=gig,
        stripe_payment_intent_id=intent.id,
        amount=gig.agreed_price,
        platform_fee=platform_fee,
        status="pending",
    )

    return intent


def process_webhook(payload: bytes, sig_header: str) -> dict:
    """Process incoming Stripe webhook events."""
    event = stripe.Webhook.construct_event(
        payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
    )
    return {"type": event.type, "data": event.data.object}
```

**Step 5: Write webhook view**

```python
# backend/apps/payments/api/__init__.py
```

```python
# backend/apps/payments/api/views.py
from django.http import HttpResponse
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.gigs.api.permissions import IsVerifiedProfessional
from apps.payments.models import Payment, PaymentStatus
from apps.payments.services import create_connect_account_link, process_webhook


class StripeConnectOnboardView(APIView):
    """Generate a Stripe Connect onboarding link for the authenticated agent."""
    permission_classes = [IsVerifiedProfessional]

    def post(self, request):
        profile = request.user.professional_profile
        url = create_connect_account_link(profile)
        return Response({"url": url})


class StripeWebhookView(APIView):
    """Handle Stripe webhook events."""
    permission_classes = [permissions.AllowAny]
    authentication_classes = []

    def post(self, request):
        try:
            event = process_webhook(
                request.body,
                request.META.get("HTTP_STRIPE_SIGNATURE", ""),
            )
        except Exception:
            return HttpResponse(status=400)

        event_type = event["type"]
        obj = event["data"]

        if event_type == "payment_intent.succeeded":
            Payment.objects.filter(
                stripe_payment_intent_id=obj["id"]
            ).update(status=PaymentStatus.CAPTURED)

        elif event_type == "payment_intent.payment_failed":
            Payment.objects.filter(
                stripe_payment_intent_id=obj["id"]
            ).update(status=PaymentStatus.FAILED)

        return HttpResponse(status=200)


class PaymentDetailView(APIView):
    """Get payment status for a gig."""
    permission_classes = [IsVerifiedProfessional]

    def get(self, request, gig_uuid):
        try:
            payment = Payment.objects.get(gig__uuid=gig_uuid)
        except Payment.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        return Response({
            "uuid": str(payment.uuid),
            "amount": str(payment.amount),
            "platform_fee": str(payment.platform_fee),
            "status": payment.status,
        })
```

Register routes:

```python
from apps.payments.api.views import PaymentDetailView, StripeConnectOnboardView, StripeWebhookView

urlpatterns += [
    path("payments/stripe-connect/", StripeConnectOnboardView.as_view(), name="stripe-connect-onboard"),
    path("payments/webhook/", StripeWebhookView.as_view(), name="stripe-webhook"),
    path("payments/<uuid:gig_uuid>/", PaymentDetailView.as_view(), name="payment-detail"),
]
```

**Step 6: Write tests (mock Stripe)**

```python
# backend/apps/payments/tests/__init__.py
```

```python
# backend/apps/payments/tests/test_models.py
import pytest
from decimal import Decimal
from apps.payments.models import Payment, PaymentStatus
from apps.gigs.tests.factories import GigFactory


@pytest.mark.django_db
class TestPayment:
    def test_create_payment(self):
        gig = GigFactory(agreed_price=Decimal("100.00"))
        payment = Payment.objects.create(
            gig=gig,
            amount=Decimal("100.00"),
            platform_fee=Decimal("10.00"),
            stripe_payment_intent_id="pi_test_123",
        )
        assert payment.status == PaymentStatus.PENDING
        assert payment.amount == Decimal("100.00")
        assert payment.platform_fee == Decimal("10.00")
```

**Step 7: Create migrations, run tests, commit**

```bash
docker compose run --rm django python manage.py makemigrations payments
docker compose run --rm django python manage.py migrate
docker compose run --rm django pytest apps/payments/ -v
git add -A
git commit -m "feat(payments): add Payment model and Stripe Connect integration"
```

---

## Phase 6: Frontend -- Professional Onboarding & Directory

### Task 10: Regenerate API Client & Add Frontend Types

**Step 1: Regenerate the OpenAPI client**

```bash
docker compose run --rm frontend npm run generate:api
```

This generates TypeScript types for all new endpoints (professionals, gigs, messaging, reviews, payments).

**Step 2: Verify types generated correctly**

```bash
docker compose run --rm frontend npm run type-check
```

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: regenerate frontend API client with new backend endpoints"
```

---

### Task 11: Professional Onboarding View

**Files:**
- Create: `frontend/src/views/onboarding/ProfessionalOnboardingView.vue`
- Create: `frontend/src/composables/useProfessionals.ts`
- Modify: `frontend/src/router/index.ts`

**Step 1: Write composable**

```typescript
// frontend/src/composables/useProfessionals.ts
import { ref } from 'vue'
import { apiClient } from '@/lib/api-client'

interface ProfessionalProfile {
  uuid: string
  license_number?: string
  license_status: string
  bio: string
  specializations: string[]
  is_available: boolean
  average_rating: number | null
  service_areas: ServiceArea[]
  user_first_name: string
  user_last_name: string
  user_email: string
  is_verified: boolean
}

interface ServiceArea {
  uuid: string
  name: string
  zip_codes: string[]
  metro: { uuid: string; name: string; state: string }
}

export function useProfessionals() {
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  const myProfile = ref<ProfessionalProfile | null>(null)
  const professionals = ref<ProfessionalProfile[]>([])
  const serviceAreas = ref<ServiceArea[]>([])

  async function fetchMyProfile(): Promise<void> {
    isLoading.value = true
    error.value = null
    try {
      const response = await apiClient.get('/api/professionals/me/')
      myProfile.value = response.data
    } catch (err: unknown) {
      if ((err as { response?: { status: number } }).response?.status === 404) {
        myProfile.value = null
      } else {
        error.value = 'Failed to load profile'
      }
    } finally {
      isLoading.value = false
    }
  }

  async function createProfile(data: {
    license_number: string
    bio: string
    specializations: string[]
    service_area_uuids: string[]
  }): Promise<void> {
    isLoading.value = true
    error.value = null
    try {
      const response = await apiClient.post('/api/professionals/me/', data)
      myProfile.value = response.data
    } catch (err: unknown) {
      error.value = 'Failed to create profile'
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function searchProfessionals(params: {
    service_area?: string
    is_available?: boolean
    min_rating?: number
  }): Promise<void> {
    isLoading.value = true
    error.value = null
    try {
      const response = await apiClient.get('/api/professionals/', { params })
      professionals.value = response.data.results
    } catch (err: unknown) {
      error.value = 'Failed to search agents'
    } finally {
      isLoading.value = false
    }
  }

  async function fetchServiceAreas(): Promise<void> {
    try {
      const response = await apiClient.get('/api/service-areas/')
      serviceAreas.value = response.data.results
    } catch (err: unknown) {
      error.value = 'Failed to load service areas'
    }
  }

  return {
    isLoading,
    error,
    myProfile,
    professionals,
    serviceAreas,
    fetchMyProfile,
    createProfile,
    searchProfessionals,
    fetchServiceAreas,
  }
}
```

**Step 2: Create the onboarding view**

Build a multi-step form:
1. License number input
2. Service area selection (checkboxes)
3. Specializations (checkboxes)
4. Bio (textarea)

Use Shadcn-vue components: Card, Input, Button, Checkbox, Textarea, Badge.

**Step 3: Add route**

In `frontend/src/router/index.ts`, add under the dashboard layout:

```typescript
{
  path: 'onboarding',
  name: 'professional-onboarding',
  component: () => import('@/views/onboarding/ProfessionalOnboardingView.vue'),
  meta: { requiresAuth: true },
},
```

**Step 4: Add route guard**

After login, check if user has a professional profile. If not, redirect to onboarding:

```typescript
// In router beforeEach guard, after auth check:
// If authenticated and no professional profile, redirect to onboarding
```

**Step 5: Write component tests**

```bash
docker compose run --rm frontend npm run test:run -- --grep "ProfessionalOnboarding"
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat(frontend): add professional onboarding flow"
```

---

### Task 12: Agent Directory View

**Files:**
- Create: `frontend/src/views/professionals/AgentDirectoryView.vue`
- Create: `frontend/src/views/professionals/AgentProfileView.vue`
- Create: `frontend/src/components/professionals/AgentCard.vue`
- Create: `frontend/src/components/professionals/AgentSearchFilters.vue`
- Modify: `frontend/src/router/index.ts`

**Step 1: Create AgentCard component**

Displays: name, avatar, rating (stars), service areas (badges), availability indicator, response time, specializations.

**Step 2: Create AgentSearchFilters component**

Filters: service area dropdown, availability toggle, minimum rating slider, specialization checkboxes.

**Step 3: Create AgentDirectoryView**

Combines AgentSearchFilters + grid of AgentCards. Uses `useProfessionals().searchProfessionals()`.

**Step 4: Create AgentProfileView**

Full profile page: all profile data, reviews list, "Invite to Gig" button. Fetches reviews from `/api/professionals/:uuid/reviews/`.

**Step 5: Add routes**

```typescript
{
  path: 'agents',
  name: 'agent-directory',
  component: () => import('@/views/professionals/AgentDirectoryView.vue'),
},
{
  path: 'agents/:uuid',
  name: 'agent-profile',
  component: () => import('@/views/professionals/AgentProfileView.vue'),
},
```

**Step 6: Update dashboard navigation**

Replace project links with agent directory link in the sidebar/nav.

**Step 7: Test and commit**

```bash
docker compose run --rm frontend npm run type-check
docker compose run --rm frontend npm run test:run
git add -A
git commit -m "feat(frontend): add agent directory and profile views"
```

---

## Phase 7: Frontend -- Gigs & Messaging

### Task 13: Gig Management Views

**Files:**
- Create: `frontend/src/composables/useGigs.ts`
- Create: `frontend/src/views/gigs/GigCreateView.vue`
- Create: `frontend/src/views/gigs/GigListView.vue`
- Create: `frontend/src/views/gigs/GigDetailView.vue`
- Create: `frontend/src/components/gigs/GigStatusBadge.vue`
- Create: `frontend/src/components/gigs/GigInvitationList.vue`
- Modify: `frontend/src/router/index.ts`

**Step 1: Write useGigs composable**

CRUD operations for gigs: create, list (own + marketplace), detail, status transitions, invitations.

**Step 2: Create GigCreateView**

Form with: title, description, location, date/time, budget range, gig type, service area. Uses Shadcn-vue form components.

**Step 3: Create GigListView**

Two tabs: "My Gigs" (posted + assigned) and "Marketplace" (all posted gigs). Each gig shows title, date, status badge, location.

**Step 4: Create GigDetailView**

Full gig detail with:
- Status timeline
- Invitation management (send invitations, view responses)
- Status transition buttons (post, accept, complete, cancel)
- Link to messaging conversation

**Step 5: Add routes**

```typescript
{
  path: 'gigs',
  name: 'gig-list',
  component: () => import('@/views/gigs/GigListView.vue'),
},
{
  path: 'gigs/create',
  name: 'gig-create',
  component: () => import('@/views/gigs/GigCreateView.vue'),
},
{
  path: 'gigs/:uuid',
  name: 'gig-detail',
  component: () => import('@/views/gigs/GigDetailView.vue'),
},
```

**Step 6: Test and commit**

```bash
docker compose run --rm frontend npm run type-check
docker compose run --rm frontend npm run test:run
git add -A
git commit -m "feat(frontend): add gig creation, listing, and detail views"
```

---

### Task 14: Messaging Views

**Files:**
- Create: `frontend/src/composables/useMessaging.ts`
- Create: `frontend/src/views/messaging/ConversationListView.vue`
- Create: `frontend/src/views/messaging/ConversationView.vue`
- Create: `frontend/src/components/messaging/MessageBubble.vue`
- Modify: `frontend/src/router/index.ts`

**Step 1: Write useMessaging composable**

Operations: list conversations, get messages, send message, poll for new messages (30-second interval).

**Step 2: Create ConversationListView**

List of conversations with: other participant name/avatar, last message preview, unread count badge, timestamp.

**Step 3: Create ConversationView**

Message thread with:
- Message bubbles (sent vs received styling)
- Input field at bottom
- Auto-scroll to latest message
- Polling for new messages every 30 seconds
- Gig context banner (if conversation is linked to a gig)

**Step 4: Add routes**

```typescript
{
  path: 'messages',
  name: 'conversation-list',
  component: () => import('@/views/messaging/ConversationListView.vue'),
},
{
  path: 'messages/:uuid',
  name: 'conversation',
  component: () => import('@/views/messaging/ConversationView.vue'),
},
```

**Step 5: Test and commit**

```bash
docker compose run --rm frontend npm run type-check
docker compose run --rm frontend npm run test:run
git add -A
git commit -m "feat(frontend): add messaging views with conversation threading"
```

---

## Phase 8: Frontend -- Payments & Dashboard

### Task 15: Stripe Connect Onboarding & Payment UI

**Files:**
- Create: `frontend/src/composables/usePayments.ts`
- Modify: `frontend/src/views/user/SettingsView.vue` (add Stripe Connect section)
- Create: `frontend/src/views/payments/StripeCompleteView.vue`
- Create: `frontend/src/components/payments/PaymentStatusBadge.vue`

**Step 1: Write usePayments composable**

Operations: initiate Stripe Connect onboarding, check payment status for a gig.

**Step 2: Add Stripe section to Settings**

In SettingsView.vue, add a section:
- If no Stripe account: "Connect your bank account to receive payments" + button
- If Stripe connected: "Payment account connected" with green badge

**Step 3: Add PaymentStatusBadge to GigDetailView**

Show payment status on accepted/completed gigs.

**Step 4: Add Stripe completion route**

```typescript
{
  path: 'settings/stripe/complete',
  name: 'stripe-complete',
  component: () => import('@/views/payments/StripeCompleteView.vue'),
},
```

**Step 5: Test and commit**

```bash
docker compose run --rm frontend npm run type-check
git add -A
git commit -m "feat(frontend): add Stripe Connect onboarding and payment status"
```

---

### Task 16: Dashboard Redesign

**Files:**
- Modify: `frontend/src/views/dashboard/DashboardView.vue`

**Step 1: Redesign dashboard**

Replace the generic dashboard with RealGig-specific widgets:

- **Active Gigs** card -- count of in-progress gigs with links
- **Pending Invitations** card -- count of invitations awaiting response
- **Unread Messages** card -- count with link to conversations
- **Recent Gigs** list -- last 5 gigs (posted or assigned)
- **Earnings Summary** card -- total earned via completed gigs (if Stripe connected)
- **Verification Status** banner -- prominent if not yet verified
- **Availability Toggle** -- quick toggle right on the dashboard

**Step 2: Test and commit**

```bash
docker compose run --rm frontend npm run type-check
docker compose run --rm frontend npm run test:run
git add -A
git commit -m "feat(frontend): redesign dashboard for RealGig"
```

---

## Phase 9: Seed Data & Polish

### Task 17: MSP Service Area Seed Data

**Files:**
- Create: `backend/apps/professionals/management/commands/seed_msp_areas.py`

**Step 1: Create management command**

```python
# backend/apps/professionals/management/commands/seed_msp_areas.py
from django.core.management.base import BaseCommand
from apps.professionals.models import Metro, ServiceArea


MSP_AREAS = [
    {"name": "Downtown Minneapolis", "zip_codes": ["55401", "55402", "55403"]},
    {"name": "Uptown", "zip_codes": ["55408", "55405"]},
    {"name": "Northeast Minneapolis", "zip_codes": ["55413", "55418"]},
    {"name": "South Minneapolis", "zip_codes": ["55406", "55407", "55409", "55417"]},
    {"name": "North Minneapolis", "zip_codes": ["55411", "55412"]},
    {"name": "Downtown St. Paul", "zip_codes": ["55101", "55102"]},
    {"name": "Highland Park", "zip_codes": ["55116"]},
    {"name": "Edina", "zip_codes": ["55424", "55435", "55436", "55439"]},
    {"name": "Bloomington", "zip_codes": ["55420", "55425", "55431", "55437", "55438"]},
    {"name": "Plymouth", "zip_codes": ["55441", "55442", "55446", "55447"]},
    {"name": "Maple Grove", "zip_codes": ["55311", "55369"]},
    {"name": "Woodbury", "zip_codes": ["55125", "55129"]},
    {"name": "Eagan", "zip_codes": ["55121", "55122", "55123"]},
    {"name": "Eden Prairie", "zip_codes": ["55344", "55346", "55347"]},
    {"name": "Burnsville", "zip_codes": ["55306", "55337"]},
    {"name": "Lakeville", "zip_codes": ["55044"]},
    {"name": "Minnetonka", "zip_codes": ["55305", "55345"]},
    {"name": "St. Louis Park", "zip_codes": ["55416", "55426"]},
    {"name": "Richfield", "zip_codes": ["55423"]},
    {"name": "Hopkins", "zip_codes": ["55343"]},
]


class Command(BaseCommand):
    help = "Seed MSP metro service areas"

    def handle(self, *args, **options):
        metro, _ = Metro.objects.get_or_create(
            name="Minneapolis-St. Paul",
            state="MN",
        )
        for area_data in MSP_AREAS:
            ServiceArea.objects.update_or_create(
                name=area_data["name"],
                metro=metro,
                defaults={"zip_codes": area_data["zip_codes"]},
            )
        self.stdout.write(self.style.SUCCESS(f"Seeded {len(MSP_AREAS)} service areas"))
```

**Step 2: Run it**

```bash
docker compose run --rm django python manage.py seed_msp_areas
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat(professionals): add MSP metro service area seed data"
```

---

### Task 18: Final Integration Test & Type Check

**Step 1: Run full backend test suite**

```bash
docker compose run --rm django pytest -v --tb=short
docker compose run --rm django mypy apps
```

**Step 2: Run full frontend checks**

```bash
docker compose run --rm frontend npm run type-check
docker compose run --rm frontend npm run test:run
```

**Step 3: Regenerate API client one final time**

```bash
docker compose run --rm frontend npm run generate:api
docker compose run --rm frontend npm run type-check
```

**Step 4: Manual smoke test**

1. Register a new account
2. Complete professional onboarding (enter license number)
3. Verify via Django admin
4. Browse agent directory (should see no one yet -- just you)
5. Create a gig, post it
6. Verify it shows in marketplace

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore: final integration verification and API client regeneration"
```

---

## Summary

| Phase | Tasks | What's Built |
|-------|-------|-------------|
| 1: Backend Foundation | 1-4 | Remove projects, professionals app (models + API + admin verification) |
| 2: Gigs | 5-6 | Gig models, lifecycle state machine, invitations API |
| 3: Messaging | 7 | Conversations, messages, API |
| 4: Reviews | 8 | Reviews with rating aggregation |
| 5: Payments | 9 | Stripe Connect integration, webhooks |
| 6: Frontend Onboarding & Directory | 10-12 | API client, onboarding flow, agent search/profiles |
| 7: Frontend Gigs & Messaging | 13-14 | Gig CRUD, messaging UI |
| 8: Frontend Payments & Dashboard | 15-16 | Stripe onboarding, dashboard redesign |
| 9: Seed Data & Polish | 17-18 | MSP areas, integration testing |

**Total: 18 tasks across 9 phases.** Each phase is independent enough to be a single work session. Backend phases (1-5) should be completed before frontend phases (6-8). Phase 9 is a final polish pass.
