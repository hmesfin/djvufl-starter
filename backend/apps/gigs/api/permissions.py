"""Permissions for the gigs app."""

from rest_framework.permissions import BasePermission
from rest_framework.request import Request
from rest_framework.views import APIView


class IsVerifiedProfessional(BasePermission):
    """Require the user to have a verified professional profile."""

    message = (
        "You must have a verified professional profile to perform this action."
    )

    def has_permission(self, request: Request, view: APIView) -> bool:
        if not request.user.is_authenticated:
            return False
        profile = getattr(request.user, "professional_profile", None)
        if profile is None:
            return False
        return profile.license_status == "verified"
