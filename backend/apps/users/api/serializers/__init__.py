"""Users app serializers - organized by responsibility."""

# User serializers
# Auth serializers
from .auth_serializers import EmailTokenObtainPairSerializer
from .auth_serializers import PasswordChangeSerializer

# OTP serializers
from .otp_serializers import OTPVerificationSerializer
from .otp_serializers import ResendOTPSerializer

# Password serializers
from .password_serializers import PasswordResetConfirmSerializer
from .password_serializers import PasswordResetOTPConfirmSerializer
from .password_serializers import PasswordResetOTPRequestSerializer
from .password_serializers import PasswordResetRequestSerializer
from .user_serializers import UserRegistrationSerializer
from .user_serializers import UserSerializer

# Export all serializers for backward compatibility
__all__ = [
    "EmailTokenObtainPairSerializer",
    "OTPVerificationSerializer",
    "PasswordChangeSerializer",
    "PasswordResetConfirmSerializer",
    "PasswordResetOTPConfirmSerializer",
    "PasswordResetOTPRequestSerializer",
    "PasswordResetRequestSerializer",
    "ResendOTPSerializer",
    "UserRegistrationSerializer",
    "UserSerializer",
]
