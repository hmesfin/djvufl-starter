import 'package:flutter/foundation.dart';

/// API Configuration
///
/// Development setup for WSL + Android Studio (Windows):
/// - Android Emulator uses 10.0.2.2 to reach host machine (Windows localhost)
/// - WSL2 auto-forwards ports to Windows localhost
/// - Therefore: Android Emulator → 10.0.2.2 → Windows localhost → WSL Docker
///
/// No brittle networking needed! This is the battle-tested pattern.
class ApiConfig {
  /// Get the API base URL based on environment and platform
  static String getApiBaseUrl() {
    if (kDebugMode) {
      // Development environment - use localhost or configurable development URL
      // This should be configured via environment variables or build flavors
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );
    }

    // Production - replace with your production API URL
    // This should be configured via environment variables or build flavors
    return const String.fromEnvironment(
      'PRODUCTION_API_URL',
      defaultValue: 'https://api.yourdomain.com',
    );
  }

  static const String apiBaseUrl = ''; // Use getApiBaseUrl() instead

  /// API timeout in milliseconds
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Token storage keys
  static const String accessTokenKey = '@auth/access_token';
  static const String refreshTokenKey = '@auth/refresh_token';
}

/// API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/api/auth/register/';
  static const String login = '/api/auth/token/';
  static const String refresh = '/api/auth/token/refresh/';
  static const String verifyOtp = '/api/auth/verify-otp/';
  static const String resendOtp = '/api/auth/resend-otp/';
  static const String passwordResetOtpRequest =
      '/api/auth/password-reset-otp/request/';
  static const String passwordResetOtpConfirm =
      '/api/auth/password-reset-otp/confirm/';

  static const String usersMe = '/api/users/me/';
  static String userUpdate(String id) => '/api/users/$id/';

  static const String projectsList = '/api/projects/';
  static String projectDetail(String id) => '/api/projects/$id/';
  static const String projectCreate = '/api/projects/';
  static String projectUpdate(String id) => '/api/projects/$id/';
  static String projectDelete(String id) => '/api/projects/$id/';
}
