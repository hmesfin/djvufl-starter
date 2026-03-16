from django.contrib import admin

from apps.reviews.models import Review


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ["gig", "reviewer", "reviewee", "rating", "is_from_poster"]
    list_filter = ["rating", "is_from_poster"]
    raw_id_fields = ["gig", "reviewer", "reviewee"]
