// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserRegistrationRequest _$UserRegistrationRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UserRegistrationRequest.fromJson(json);
}

/// @nodoc
mixin _$UserRegistrationRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;

  /// Serializes this UserRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserRegistrationRequestCopyWith<UserRegistrationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRegistrationRequestCopyWith<$Res> {
  factory $UserRegistrationRequestCopyWith(
    UserRegistrationRequest value,
    $Res Function(UserRegistrationRequest) then,
  ) = _$UserRegistrationRequestCopyWithImpl<$Res, UserRegistrationRequest>;
  @useResult
  $Res call({String email, String password, String firstName, String lastName});
}

/// @nodoc
class _$UserRegistrationRequestCopyWithImpl<
  $Res,
  $Val extends UserRegistrationRequest
>
    implements $UserRegistrationRequestCopyWith<$Res> {
  _$UserRegistrationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? firstName = null,
    Object? lastName = null,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserRegistrationRequestImplCopyWith<$Res>
    implements $UserRegistrationRequestCopyWith<$Res> {
  factory _$$UserRegistrationRequestImplCopyWith(
    _$UserRegistrationRequestImpl value,
    $Res Function(_$UserRegistrationRequestImpl) then,
  ) = __$$UserRegistrationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password, String firstName, String lastName});
}

/// @nodoc
class __$$UserRegistrationRequestImplCopyWithImpl<$Res>
    extends
        _$UserRegistrationRequestCopyWithImpl<
          $Res,
          _$UserRegistrationRequestImpl
        >
    implements _$$UserRegistrationRequestImplCopyWith<$Res> {
  __$$UserRegistrationRequestImplCopyWithImpl(
    _$UserRegistrationRequestImpl _value,
    $Res Function(_$UserRegistrationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? firstName = null,
    Object? lastName = null,
  }) {
    return _then(
      _$UserRegistrationRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRegistrationRequestImpl implements _UserRegistrationRequest {
  const _$UserRegistrationRequestImpl({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  factory _$UserRegistrationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRegistrationRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;
  @override
  final String firstName;
  @override
  final String lastName;

  @override
  String toString() {
    return 'UserRegistrationRequest(email: $email, password: $password, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRegistrationRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, email, password, firstName, lastName);

  /// Create a copy of UserRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRegistrationRequestImplCopyWith<_$UserRegistrationRequestImpl>
  get copyWith =>
      __$$UserRegistrationRequestImplCopyWithImpl<
        _$UserRegistrationRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRegistrationRequestImplToJson(this);
  }
}

abstract class _UserRegistrationRequest implements UserRegistrationRequest {
  const factory _UserRegistrationRequest({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
  }) = _$UserRegistrationRequestImpl;

  factory _UserRegistrationRequest.fromJson(Map<String, dynamic> json) =
      _$UserRegistrationRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;
  @override
  String get firstName;
  @override
  String get lastName;

  /// Create a copy of UserRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserRegistrationRequestImplCopyWith<_$UserRegistrationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
    LoginRequest value,
    $Res Function(LoginRequest) then,
  ) = _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
    _$LoginRequestImpl value,
    $Res Function(_$LoginRequestImpl) then,
  ) = __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
    _$LoginRequestImpl _value,
    $Res Function(_$LoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$LoginRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl({required this.email, required this.password});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(this);
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest({
    required final String email,
    required final String password,
  }) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OtpVerificationRequest _$OtpVerificationRequestFromJson(
  Map<String, dynamic> json,
) {
  return _OtpVerificationRequest.fromJson(json);
}

/// @nodoc
mixin _$OtpVerificationRequest {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'code')
  String get otpCode => throw _privateConstructorUsedError;

  /// Serializes this OtpVerificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtpVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpVerificationRequestCopyWith<OtpVerificationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpVerificationRequestCopyWith<$Res> {
  factory $OtpVerificationRequestCopyWith(
    OtpVerificationRequest value,
    $Res Function(OtpVerificationRequest) then,
  ) = _$OtpVerificationRequestCopyWithImpl<$Res, OtpVerificationRequest>;
  @useResult
  $Res call({String email, @JsonKey(name: 'code') String otpCode});
}

/// @nodoc
class _$OtpVerificationRequestCopyWithImpl<
  $Res,
  $Val extends OtpVerificationRequest
>
    implements $OtpVerificationRequestCopyWith<$Res> {
  _$OtpVerificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? otpCode = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            otpCode: null == otpCode
                ? _value.otpCode
                : otpCode // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OtpVerificationRequestImplCopyWith<$Res>
    implements $OtpVerificationRequestCopyWith<$Res> {
  factory _$$OtpVerificationRequestImplCopyWith(
    _$OtpVerificationRequestImpl value,
    $Res Function(_$OtpVerificationRequestImpl) then,
  ) = __$$OtpVerificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, @JsonKey(name: 'code') String otpCode});
}

/// @nodoc
class __$$OtpVerificationRequestImplCopyWithImpl<$Res>
    extends
        _$OtpVerificationRequestCopyWithImpl<$Res, _$OtpVerificationRequestImpl>
    implements _$$OtpVerificationRequestImplCopyWith<$Res> {
  __$$OtpVerificationRequestImplCopyWithImpl(
    _$OtpVerificationRequestImpl _value,
    $Res Function(_$OtpVerificationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OtpVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? otpCode = null}) {
    return _then(
      _$OtpVerificationRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        otpCode: null == otpCode
            ? _value.otpCode
            : otpCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpVerificationRequestImpl implements _OtpVerificationRequest {
  const _$OtpVerificationRequestImpl({
    required this.email,
    @JsonKey(name: 'code') required this.otpCode,
  });

  factory _$OtpVerificationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpVerificationRequestImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'code')
  final String otpCode;

  @override
  String toString() {
    return 'OtpVerificationRequest(email: $email, otpCode: $otpCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpVerificationRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otpCode, otpCode) || other.otpCode == otpCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, otpCode);

  /// Create a copy of OtpVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpVerificationRequestImplCopyWith<_$OtpVerificationRequestImpl>
  get copyWith =>
      __$$OtpVerificationRequestImplCopyWithImpl<_$OtpVerificationRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpVerificationRequestImplToJson(this);
  }
}

abstract class _OtpVerificationRequest implements OtpVerificationRequest {
  const factory _OtpVerificationRequest({
    required final String email,
    @JsonKey(name: 'code') required final String otpCode,
  }) = _$OtpVerificationRequestImpl;

  factory _OtpVerificationRequest.fromJson(Map<String, dynamic> json) =
      _$OtpVerificationRequestImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'code')
  String get otpCode;

  /// Create a copy of OtpVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpVerificationRequestImplCopyWith<_$OtpVerificationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) {
  return _TokenRefreshRequest.fromJson(json);
}

/// @nodoc
mixin _$TokenRefreshRequest {
  String get refresh => throw _privateConstructorUsedError;

  /// Serializes this TokenRefreshRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenRefreshRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenRefreshRequestCopyWith<TokenRefreshRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenRefreshRequestCopyWith<$Res> {
  factory $TokenRefreshRequestCopyWith(
    TokenRefreshRequest value,
    $Res Function(TokenRefreshRequest) then,
  ) = _$TokenRefreshRequestCopyWithImpl<$Res, TokenRefreshRequest>;
  @useResult
  $Res call({String refresh});
}

/// @nodoc
class _$TokenRefreshRequestCopyWithImpl<$Res, $Val extends TokenRefreshRequest>
    implements $TokenRefreshRequestCopyWith<$Res> {
  _$TokenRefreshRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenRefreshRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refresh = null}) {
    return _then(
      _value.copyWith(
            refresh: null == refresh
                ? _value.refresh
                : refresh // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokenRefreshRequestImplCopyWith<$Res>
    implements $TokenRefreshRequestCopyWith<$Res> {
  factory _$$TokenRefreshRequestImplCopyWith(
    _$TokenRefreshRequestImpl value,
    $Res Function(_$TokenRefreshRequestImpl) then,
  ) = __$$TokenRefreshRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String refresh});
}

/// @nodoc
class __$$TokenRefreshRequestImplCopyWithImpl<$Res>
    extends _$TokenRefreshRequestCopyWithImpl<$Res, _$TokenRefreshRequestImpl>
    implements _$$TokenRefreshRequestImplCopyWith<$Res> {
  __$$TokenRefreshRequestImplCopyWithImpl(
    _$TokenRefreshRequestImpl _value,
    $Res Function(_$TokenRefreshRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenRefreshRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refresh = null}) {
    return _then(
      _$TokenRefreshRequestImpl(
        refresh: null == refresh
            ? _value.refresh
            : refresh // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenRefreshRequestImpl implements _TokenRefreshRequest {
  const _$TokenRefreshRequestImpl({required this.refresh});

  factory _$TokenRefreshRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenRefreshRequestImplFromJson(json);

  @override
  final String refresh;

  @override
  String toString() {
    return 'TokenRefreshRequest(refresh: $refresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenRefreshRequestImpl &&
            (identical(other.refresh, refresh) || other.refresh == refresh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, refresh);

  /// Create a copy of TokenRefreshRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenRefreshRequestImplCopyWith<_$TokenRefreshRequestImpl> get copyWith =>
      __$$TokenRefreshRequestImplCopyWithImpl<_$TokenRefreshRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenRefreshRequestImplToJson(this);
  }
}

abstract class _TokenRefreshRequest implements TokenRefreshRequest {
  const factory _TokenRefreshRequest({required final String refresh}) =
      _$TokenRefreshRequestImpl;

  factory _TokenRefreshRequest.fromJson(Map<String, dynamic> json) =
      _$TokenRefreshRequestImpl.fromJson;

  @override
  String get refresh;

  /// Create a copy of TokenRefreshRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenRefreshRequestImplCopyWith<_$TokenRefreshRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PasswordResetOtpRequest _$PasswordResetOtpRequestFromJson(
  Map<String, dynamic> json,
) {
  return _PasswordResetOtpRequest.fromJson(json);
}

/// @nodoc
mixin _$PasswordResetOtpRequest {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this PasswordResetOtpRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasswordResetOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordResetOtpRequestCopyWith<PasswordResetOtpRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordResetOtpRequestCopyWith<$Res> {
  factory $PasswordResetOtpRequestCopyWith(
    PasswordResetOtpRequest value,
    $Res Function(PasswordResetOtpRequest) then,
  ) = _$PasswordResetOtpRequestCopyWithImpl<$Res, PasswordResetOtpRequest>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$PasswordResetOtpRequestCopyWithImpl<
  $Res,
  $Val extends PasswordResetOtpRequest
>
    implements $PasswordResetOtpRequestCopyWith<$Res> {
  _$PasswordResetOtpRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordResetOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordResetOtpRequestImplCopyWith<$Res>
    implements $PasswordResetOtpRequestCopyWith<$Res> {
  factory _$$PasswordResetOtpRequestImplCopyWith(
    _$PasswordResetOtpRequestImpl value,
    $Res Function(_$PasswordResetOtpRequestImpl) then,
  ) = __$$PasswordResetOtpRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$PasswordResetOtpRequestImplCopyWithImpl<$Res>
    extends
        _$PasswordResetOtpRequestCopyWithImpl<
          $Res,
          _$PasswordResetOtpRequestImpl
        >
    implements _$$PasswordResetOtpRequestImplCopyWith<$Res> {
  __$$PasswordResetOtpRequestImplCopyWithImpl(
    _$PasswordResetOtpRequestImpl _value,
    $Res Function(_$PasswordResetOtpRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordResetOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$PasswordResetOtpRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PasswordResetOtpRequestImpl implements _PasswordResetOtpRequest {
  const _$PasswordResetOtpRequestImpl({required this.email});

  factory _$PasswordResetOtpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PasswordResetOtpRequestImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'PasswordResetOtpRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetOtpRequestImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of PasswordResetOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetOtpRequestImplCopyWith<_$PasswordResetOtpRequestImpl>
  get copyWith =>
      __$$PasswordResetOtpRequestImplCopyWithImpl<
        _$PasswordResetOtpRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PasswordResetOtpRequestImplToJson(this);
  }
}

abstract class _PasswordResetOtpRequest implements PasswordResetOtpRequest {
  const factory _PasswordResetOtpRequest({required final String email}) =
      _$PasswordResetOtpRequestImpl;

  factory _PasswordResetOtpRequest.fromJson(Map<String, dynamic> json) =
      _$PasswordResetOtpRequestImpl.fromJson;

  @override
  String get email;

  /// Create a copy of PasswordResetOtpRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetOtpRequestImplCopyWith<_$PasswordResetOtpRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PasswordResetOtpConfirmRequest _$PasswordResetOtpConfirmRequestFromJson(
  Map<String, dynamic> json,
) {
  return _PasswordResetOtpConfirmRequest.fromJson(json);
}

/// @nodoc
mixin _$PasswordResetOtpConfirmRequest {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'code')
  String get otpCode => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this PasswordResetOtpConfirmRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasswordResetOtpConfirmRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordResetOtpConfirmRequestCopyWith<PasswordResetOtpConfirmRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordResetOtpConfirmRequestCopyWith<$Res> {
  factory $PasswordResetOtpConfirmRequestCopyWith(
    PasswordResetOtpConfirmRequest value,
    $Res Function(PasswordResetOtpConfirmRequest) then,
  ) =
      _$PasswordResetOtpConfirmRequestCopyWithImpl<
        $Res,
        PasswordResetOtpConfirmRequest
      >;
  @useResult
  $Res call({
    String email,
    @JsonKey(name: 'code') String otpCode,
    String password,
  });
}

/// @nodoc
class _$PasswordResetOtpConfirmRequestCopyWithImpl<
  $Res,
  $Val extends PasswordResetOtpConfirmRequest
>
    implements $PasswordResetOtpConfirmRequestCopyWith<$Res> {
  _$PasswordResetOtpConfirmRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordResetOtpConfirmRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? otpCode = null,
    Object? password = null,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            otpCode: null == otpCode
                ? _value.otpCode
                : otpCode // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordResetOtpConfirmRequestImplCopyWith<$Res>
    implements $PasswordResetOtpConfirmRequestCopyWith<$Res> {
  factory _$$PasswordResetOtpConfirmRequestImplCopyWith(
    _$PasswordResetOtpConfirmRequestImpl value,
    $Res Function(_$PasswordResetOtpConfirmRequestImpl) then,
  ) = __$$PasswordResetOtpConfirmRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    @JsonKey(name: 'code') String otpCode,
    String password,
  });
}

/// @nodoc
class __$$PasswordResetOtpConfirmRequestImplCopyWithImpl<$Res>
    extends
        _$PasswordResetOtpConfirmRequestCopyWithImpl<
          $Res,
          _$PasswordResetOtpConfirmRequestImpl
        >
    implements _$$PasswordResetOtpConfirmRequestImplCopyWith<$Res> {
  __$$PasswordResetOtpConfirmRequestImplCopyWithImpl(
    _$PasswordResetOtpConfirmRequestImpl _value,
    $Res Function(_$PasswordResetOtpConfirmRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordResetOtpConfirmRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? otpCode = null,
    Object? password = null,
  }) {
    return _then(
      _$PasswordResetOtpConfirmRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        otpCode: null == otpCode
            ? _value.otpCode
            : otpCode // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PasswordResetOtpConfirmRequestImpl
    implements _PasswordResetOtpConfirmRequest {
  const _$PasswordResetOtpConfirmRequestImpl({
    required this.email,
    @JsonKey(name: 'code') required this.otpCode,
    required this.password,
  });

  factory _$PasswordResetOtpConfirmRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PasswordResetOtpConfirmRequestImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'code')
  final String otpCode;
  @override
  final String password;

  @override
  String toString() {
    return 'PasswordResetOtpConfirmRequest(email: $email, otpCode: $otpCode, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetOtpConfirmRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.otpCode, otpCode) || other.otpCode == otpCode) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, otpCode, password);

  /// Create a copy of PasswordResetOtpConfirmRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetOtpConfirmRequestImplCopyWith<
    _$PasswordResetOtpConfirmRequestImpl
  >
  get copyWith =>
      __$$PasswordResetOtpConfirmRequestImplCopyWithImpl<
        _$PasswordResetOtpConfirmRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PasswordResetOtpConfirmRequestImplToJson(this);
  }
}

abstract class _PasswordResetOtpConfirmRequest
    implements PasswordResetOtpConfirmRequest {
  const factory _PasswordResetOtpConfirmRequest({
    required final String email,
    @JsonKey(name: 'code') required final String otpCode,
    required final String password,
  }) = _$PasswordResetOtpConfirmRequestImpl;

  factory _PasswordResetOtpConfirmRequest.fromJson(Map<String, dynamic> json) =
      _$PasswordResetOtpConfirmRequestImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'code')
  String get otpCode;
  @override
  String get password;

  /// Create a copy of PasswordResetOtpConfirmRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetOtpConfirmRequestImplCopyWith<
    _$PasswordResetOtpConfirmRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  String get access => throw _privateConstructorUsedError;
  String get refresh => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({String access, String refresh});
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? access = null, Object? refresh = null}) {
    return _then(
      _value.copyWith(
            access: null == access
                ? _value.access
                : access // ignore: cast_nullable_to_non_nullable
                      as String,
            refresh: null == refresh
                ? _value.refresh
                : refresh // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String access, String refresh});
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? access = null, Object? refresh = null}) {
    return _then(
      _$AuthResponseImpl(
        access: null == access
            ? _value.access
            : access // ignore: cast_nullable_to_non_nullable
                  as String,
        refresh: null == refresh
            ? _value.refresh
            : refresh // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({required this.access, required this.refresh});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final String access;
  @override
  final String refresh;

  @override
  String toString() {
    return 'AuthResponse(access: $access, refresh: $refresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.access, access) || other.access == access) &&
            (identical(other.refresh, refresh) || other.refresh == refresh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, access, refresh);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({
    required final String access,
    required final String refresh,
  }) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  String get access;
  @override
  String get refresh;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_email_verified')
  bool get isEmailVerified => throw _privateConstructorUsedError;
  String? get profilePicture => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String email,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    @JsonKey(name: 'is_email_verified') bool isEmailVerified,
    String? profilePicture,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? isEmailVerified = null,
    Object? profilePicture = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            isEmailVerified: null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            profilePicture: freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    @JsonKey(name: 'is_email_verified') bool isEmailVerified,
    String? profilePicture,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? isEmailVerified = null,
    Object? profilePicture = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        isEmailVerified: null == isEmailVerified
            ? _value.isEmailVerified
            : isEmailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        profilePicture: freezed == profilePicture
            ? _value.profilePicture
            : profilePicture // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.email,
    @JsonKey(name: 'first_name') required this.firstName,
    @JsonKey(name: 'last_name') required this.lastName,
    @JsonKey(name: 'is_email_verified') required this.isEmailVerified,
    this.profilePicture,
  });

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  @override
  final String? profilePicture;

  @override
  String toString() {
    return 'UserModel(email: $email, firstName: $firstName, lastName: $lastName, isEmailVerified: $isEmailVerified, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    firstName,
    lastName,
    isEmailVerified,
    profilePicture,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String email,
    @JsonKey(name: 'first_name') required final String firstName,
    @JsonKey(name: 'last_name') required final String lastName,
    @JsonKey(name: 'is_email_verified') required final bool isEmailVerified,
    final String? profilePicture,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  @JsonKey(name: 'is_email_verified')
  bool get isEmailVerified;
  @override
  String? get profilePicture;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
