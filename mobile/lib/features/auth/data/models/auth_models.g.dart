// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRegistrationRequestImpl _$$UserRegistrationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UserRegistrationRequestImpl(
  email: json['email'] as String,
  password: json['password'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$$UserRegistrationRequestImplToJson(
  _$UserRegistrationRequestImpl instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_$OtpVerificationRequestImpl _$$OtpVerificationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OtpVerificationRequestImpl(
  email: json['email'] as String,
  otpCode: json['code'] as String,
);

Map<String, dynamic> _$$OtpVerificationRequestImplToJson(
  _$OtpVerificationRequestImpl instance,
) => <String, dynamic>{'email': instance.email, 'code': instance.otpCode};

_$TokenRefreshRequestImpl _$$TokenRefreshRequestImplFromJson(
  Map<String, dynamic> json,
) => _$TokenRefreshRequestImpl(refresh: json['refresh'] as String);

Map<String, dynamic> _$$TokenRefreshRequestImplToJson(
  _$TokenRefreshRequestImpl instance,
) => <String, dynamic>{'refresh': instance.refresh};

_$PasswordResetOtpRequestImpl _$$PasswordResetOtpRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PasswordResetOtpRequestImpl(email: json['email'] as String);

Map<String, dynamic> _$$PasswordResetOtpRequestImplToJson(
  _$PasswordResetOtpRequestImpl instance,
) => <String, dynamic>{'email': instance.email};

_$PasswordResetOtpConfirmRequestImpl
_$$PasswordResetOtpConfirmRequestImplFromJson(Map<String, dynamic> json) =>
    _$PasswordResetOtpConfirmRequestImpl(
      email: json['email'] as String,
      otpCode: json['code'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$PasswordResetOtpConfirmRequestImplToJson(
  _$PasswordResetOtpConfirmRequestImpl instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.otpCode,
  'password': instance.password,
};

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{'access': instance.access, 'refresh': instance.refresh};

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      isEmailVerified: json['is_email_verified'] as bool,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'is_email_verified': instance.isEmailVerified,
      'profilePicture': instance.profilePicture,
    };
