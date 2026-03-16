from django.contrib import admin
from django.utils import timezone

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
    search_fields = [
        "user__email",
        "user__first_name",
        "user__last_name",
        "license_number",
    ]
    readonly_fields = [
        "verified_at",
        "verified_by",
        "average_rating",
        "average_response_time",
    ]
    raw_id_fields = ["user", "verified_by"]
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
