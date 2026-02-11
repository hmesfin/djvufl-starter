import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/auth_models.dart';
import '../../../../config/api.dart';

/// Authentication Service
///
/// Handles all authentication-related API calls:
/// - User registration
/// - Login (JWT token obtain)
/// - OTP verification
/// - OTP resend
/// - Token refresh
/// - Get current user
/// - Password reset
class AuthService {
  AuthService(this._client);

  final DioClient _client;

  /// Register a new user
  /// Returns User data (email not yet verified)
  Future<UserModel> register(UserRegistrationRequest data) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: data.toJson(),
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Registration failed'));
    }
  }

  /// Login (obtain JWT tokens)
  /// Returns Access and refresh tokens
  Future<AuthResponse> login(LoginRequest data) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: data.toJson(),
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.auth(message: 'Login failed'));
    }
  }

  /// Verify email with OTP code
  /// Returns Success message
  Future<Map<String, dynamic>> verifyOTP(OtpVerificationRequest data) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: data.toJson(),
      );
      return response.data!;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'OTP verification failed'));
    }
  }

  /// Resend OTP verification code
  /// Returns Success message
  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );
      return response.data!;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to resend OTP'));
    }
  }

  /// Refresh access token using refresh token
  /// Returns New access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: TokenRefreshRequest(refresh: refreshToken).toJson(),
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.auth(message: 'Token refresh failed'));
    }
  }

  /// Get current authenticated user data
  /// Returns Current user data
  Future<UserModel> getMe() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.usersMe,
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Failed to get user data'));
    }
  }

  /// Request password reset OTP
  /// Returns Success message
  Future<Map<String, dynamic>> requestPasswordResetOTP(
    PasswordResetOtpRequest data,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.passwordResetOtpRequest,
        data: data.toJson(),
      );
      return response.data!;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Password reset request failed'));
    }
  }

  /// Confirm password reset with OTP code
  /// Returns Success message
  Future<Map<String, dynamic>> confirmPasswordResetOTP(
    PasswordResetOtpConfirmRequest data,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.passwordResetOtpConfirm,
        data: data.toJson(),
      );
      return response.data!;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw const AppException(AppFailure.unknown(message: 'Password reset confirmation failed'));
    }
  }
}
