from django.contrib import admin

from apps.gigs.models import Gig, GigInvitation


@admin.register(Gig)
class GigAdmin(admin.ModelAdmin):
    list_display = [
        "title",
        "posted_by",
        "assigned_to",
        "status",
        "gig_type",
        "scheduled_date",
    ]
    list_filter = ["status", "gig_type"]
    search_fields = ["title", "description", "location_address"]
    raw_id_fields = ["posted_by", "assigned_to", "service_area"]


@admin.register(GigInvitation)
class GigInvitationAdmin(admin.ModelAdmin):
    list_display = ["gig", "invited_agent", "proposed_rate", "status"]
    list_filter = ["status"]
    raw_id_fields = ["gig", "invited_agent"]
