from django.conf import settings
from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework.routers import SimpleRouter

from apps.gigs.api.views import (
    GigDetailView,
    GigInvitationDetailView,
    GigInvitationListCreateView,
    GigListCreateView,
    GigStatusTransitionView,
)
from apps.messaging.api.views import (
    ConversationListCreateView,
    MessageListCreateView,
)
from apps.payments.api.views import (
    PaymentDetailView,
    StripeConnectOnboardView,
    StripeWebhookView,
)
from apps.reviews.api.views import (
    ProfessionalReviewListView,
    ReviewCreateView,
)
from apps.professionals.api.views import MetroListView
from apps.professionals.api.views import MyProfessionalProfileView
from apps.professionals.api.views import ProfessionalProfileDetailView
from apps.professionals.api.views import ProfessionalProfileListView
from apps.professionals.api.views import ServiceAreaListView
from apps.users.api.views import EmailTokenObtainPairView
from apps.users.api.views import EmailTokenRefreshView
from apps.users.api.views import OTPVerificationView
from apps.users.api.views import PasswordChangeView
from apps.users.api.views import PasswordResetConfirmView
from apps.users.api.views import PasswordResetOTPConfirmView
from apps.users.api.views import PasswordResetOTPRequestView
from apps.users.api.views import PasswordResetRequestView
from apps.users.api.views import ResendOTPView
from apps.users.api.views import UserRegistrationView
from apps.users.api.views import UserViewSet

router = DefaultRouter() if settings.DEBUG else SimpleRouter()

router.register("users", UserViewSet)


app_name = "api"
urlpatterns = [
    # User-specific endpoints (must come before router.urls to avoid conflicts)
    path(
        "users/change-password/",
        PasswordChangeView.as_view(),
        name="user-change-password",
    ),
    # Router URLs (includes UserViewSet)
    *router.urls,
    # Auth endpoints
    path("auth/register/", UserRegistrationView.as_view(), name="auth-register"),
    path("auth/verify-otp/", OTPVerificationView.as_view(), name="auth-verify-otp"),
    path("auth/resend-otp/", ResendOTPView.as_view(), name="auth-resend-otp"),
    path(
        "auth/password-reset/request/",
        PasswordResetRequestView.as_view(),
        name="auth-password-reset-request",
    ),
    path(
        "auth/password-reset/confirm/",
        PasswordResetConfirmView.as_view(),
        name="auth-password-reset-confirm",
    ),
    path(
        "auth/password-reset-otp/request/",
        PasswordResetOTPRequestView.as_view(),
        name="auth-password-reset-otp-request",
    ),
    path(
        "auth/password-reset-otp/confirm/",
        PasswordResetOTPConfirmView.as_view(),
        name="auth-password-reset-otp-confirm",
    ),
    path("auth/token/", EmailTokenObtainPairView.as_view(), name="auth-token"),
    path(
        "auth/token/refresh/",
        EmailTokenRefreshView.as_view(),
        name="auth-token-refresh",
    ),
    # Professional endpoints (me/ must come before <uuid:uuid>/)
    path(
        "professionals/me/",
        MyProfessionalProfileView.as_view(),
        name="professional-me",
    ),
    path(
        "professionals/",
        ProfessionalProfileListView.as_view(),
        name="professional-list",
    ),
    path(
        "professionals/<uuid:uuid>/",
        ProfessionalProfileDetailView.as_view(),
        name="professional-detail",
    ),
    # Service areas and metros
    path("service-areas/", ServiceAreaListView.as_view(), name="servicearea-list"),
    path("metros/", MetroListView.as_view(), name="metro-list"),
    # Gig endpoints
    path("gigs/", GigListCreateView.as_view(), name="gig-list"),
    path("gigs/<uuid:uuid>/", GigDetailView.as_view(), name="gig-detail"),
    path(
        "gigs/<uuid:uuid>/transition/",
        GigStatusTransitionView.as_view(),
        name="gig-transition",
    ),
    path(
        "gigs/<uuid:gig_uuid>/invitations/",
        GigInvitationListCreateView.as_view(),
        name="gig-invitation-list",
    ),
    path(
        "gigs/<uuid:gig_uuid>/invitations/<uuid:uuid>/",
        GigInvitationDetailView.as_view(),
        name="gig-invitation-detail",
    ),
    # Messaging endpoints
    path(
        "conversations/",
        ConversationListCreateView.as_view(),
        name="conversation-list",
    ),
    path(
        "conversations/<uuid:conversation_uuid>/messages/",
        MessageListCreateView.as_view(),
        name="message-list",
    ),
    # Review endpoints
    path("reviews/", ReviewCreateView.as_view(), name="review-create"),
    path(
        "professionals/<uuid:uuid>/reviews/",
        ProfessionalReviewListView.as_view(),
        name="professional-reviews",
    ),
    # Payment endpoints
    path(
        "payments/stripe-connect/",
        StripeConnectOnboardView.as_view(),
        name="stripe-connect-onboard",
    ),
    path(
        "payments/webhook/",
        StripeWebhookView.as_view(),
        name="stripe-webhook",
    ),
    path(
        "payments/<uuid:gig_uuid>/",
        PaymentDetailView.as_view(),
        name="payment-detail",
    ),
]
