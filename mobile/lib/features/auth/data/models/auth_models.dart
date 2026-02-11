import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// User registration request
@freezed
class UserRegistrationRequest with _$UserRegistrationRequest {
  const factory UserRegistrationRequest({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) = _UserRegistrationRequest;

  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationRequestFromJson(json);
}

/// Login request (email + password)
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// OTP verification request
@freezed
class OtpVerificationRequest with _$OtpVerificationRequest {
  const factory OtpVerificationRequest({
    required String email,
    required String otpCode,
  }) = _OtpVerificationRequest;

  factory OtpVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerificationRequestFromJson(json);
}

/// Token refresh request
@freezed
class TokenRefreshRequest with _$TokenRefreshRequest {
  const factory TokenRefreshRequest({required String refresh}) =
      _TokenRefreshRequest;

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshRequestFromJson(json);
}

/// Password reset OTP request
@freezed
class PasswordResetOtpRequest with _$PasswordResetOtpRequest {
  const factory PasswordResetOtpRequest({required String email}) =
      _PasswordResetOtpRequest;

  factory PasswordResetOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetOtpRequestFromJson(json);
}

/// Password reset OTP confirm request
@freezed
class PasswordResetOtpConfirmRequest with _$PasswordResetOtpConfirmRequest {
  const factory PasswordResetOtpConfirmRequest({
    required String email,
    required String otpCode,
    required String password,
  }) = _PasswordResetOtpConfirmRequest;

  factory PasswordResetOtpConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetOtpConfirmRequestFromJson(json);
}

/// Auth response containing tokens
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String access,
    required String refresh,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// User model
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String email,
    required String firstName,
    required String lastName,
    required bool isEmailVerified,
    String? profilePicture,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
