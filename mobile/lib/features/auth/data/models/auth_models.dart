import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// ignore_for_file: invalid_annotation_target

/// User registration request
@freezed
class UserRegistrationRequest with _$UserRegistrationRequest {
  const factory UserRegistrationRequest({
    required String email,
    required String password,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
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
    @JsonKey(name: 'code') required String otpCode,
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
    @JsonKey(name: 'code') required String otpCode,
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
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    // The /api/users/me/ UserSerializer does not expose this field, so it must
    // default rather than be required (else fromJson throws on a missing key).
    @JsonKey(name: 'is_email_verified') @Default(false) bool isEmailVerified,
    // Backend field is `avatar`.
    @JsonKey(name: 'avatar') String? profilePicture,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
