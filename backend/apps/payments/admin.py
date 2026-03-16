from django.contrib import admin

from apps.payments.models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ["gig", "amount", "platform_fee", "status"]
    list_filter = ["status"]
    raw_id_fields = ["gig"]
    readonly_fields = ["stripe_payment_intent_id", "stripe_transfer_id"]
