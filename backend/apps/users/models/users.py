from typing import ClassVar

from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import BooleanField
from django.db.models import CharField
from django.db.models import EmailField
from django.db.models import ImageField
from django.urls import reverse
from django.utils.translation import gettext_lazy as _

from apps.shared.models import BaseModel
from apps.users.managers import UserManager


def validate_image_size(image: models.fields.files.FieldFile) -> None:
    """Validate uploaded image file size (max 5MB)."""
    max_size_mb = 5
    max_size_bytes = max_size_mb * 1024 * 1024
    if image.size > max_size_bytes:
        msg = f"Image file size cannot exceed {max_size_mb}MB"
        raise ValidationError(msg)


class User(AbstractUser, BaseModel):
    """
    Default custom user model for Project Slug.
    If adding fields that need to be filled at user signup,
    check forms.SignupForm and forms.SocialSignupForms accordingly.
    """

    first_name = CharField(_("first name"), max_length=150)
    last_name = CharField(_("last name"), max_length=150)
    email = EmailField(_("email address"), unique=True)
    username = None  # type: ignore[assignment]
    is_email_verified = BooleanField(_("email verified"), default=False)
    avatar = ImageField(
        _("avatar"),
        upload_to="avatars/",
        blank=True,
        null=True,
        validators=[validate_image_size],
    )

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["first_name", "last_name"]

    objects: ClassVar[UserManager] = UserManager()

    def get_absolute_url(self) -> str:
        """Get URL for user's detail view.

        Returns:
            str: URL for user detail.

        """
        return reverse("api:user-detail", kwargs={"pk": self.id})
