import pytest
from django.contrib.admin.sites import AdminSite
from django.test import RequestFactory
from django.utils import timezone

from apps.professionals.admin import ProfessionalProfileAdmin
from apps.professionals.models import LicenseStatus, ProfessionalProfile
from apps.professionals.tests.factories import ProfessionalProfileFactory
from apps.users.tests.factories import UserFactory


@pytest.mark.django_db
class TestVerifyProfileAction:
    def test_verify_profile(self):
        profile = ProfessionalProfileFactory(license_status="pending_verification")
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin_instance = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = RequestFactory().post("/admin/")
        request.user = admin_user

        queryset = ProfessionalProfile.objects.filter(pk=profile.pk)
        admin_instance.verify_profile(request, queryset)

        profile.refresh_from_db()
        assert profile.license_status == LicenseStatus.VERIFIED
        assert profile.verified_by == admin_user
        assert profile.verified_at is not None

    def test_verify_multiple_profiles(self):
        profiles = ProfessionalProfileFactory.create_batch(3)
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin_instance = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = RequestFactory().post("/admin/")
        request.user = admin_user

        queryset = ProfessionalProfile.objects.filter(
            pk__in=[p.pk for p in profiles]
        )
        admin_instance.verify_profile(request, queryset)

        for profile in profiles:
            profile.refresh_from_db()
            assert profile.license_status == LicenseStatus.VERIFIED
            assert profile.verified_by == admin_user
            assert profile.verified_at is not None


@pytest.mark.django_db
class TestRejectProfileAction:
    def test_reject_profile(self):
        profile = ProfessionalProfileFactory(license_status="pending_verification")
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin_instance = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = RequestFactory().post("/admin/")
        request.user = admin_user

        queryset = ProfessionalProfile.objects.filter(pk=profile.pk)
        admin_instance.reject_profile(request, queryset)

        profile.refresh_from_db()
        assert profile.license_status == LicenseStatus.REJECTED

    def test_reject_multiple_profiles(self):
        profiles = ProfessionalProfileFactory.create_batch(3)
        admin_user = UserFactory(is_staff=True, is_superuser=True)

        admin_instance = ProfessionalProfileAdmin(ProfessionalProfile, AdminSite())
        request = RequestFactory().post("/admin/")
        request.user = admin_user

        queryset = ProfessionalProfile.objects.filter(
            pk__in=[p.pk for p in profiles]
        )
        admin_instance.reject_profile(request, queryset)

        for profile in profiles:
            profile.refresh_from_db()
            assert profile.license_status == LicenseStatus.REJECTED
