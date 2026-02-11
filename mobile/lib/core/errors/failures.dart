import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base failure class for all app errors
@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;

  const factory AppFailure.auth({
    required String message,
  }) = AuthFailure;

  const factory AppFailure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  const factory AppFailure.notFound({
    required String message,
  }) = NotFoundFailure;

  const factory AppFailure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory AppFailure.unknown({
    required String message,
    Object? exception,
  }) = UnknownFailure;
}

/// Exception class that can be thrown and caught
class AppException implements Exception {
  final AppFailure failure;

  const AppException(this.failure);

  @override
  String toString() => failure.when(
        network: (message, statusCode) =>
            'NetworkError: $message${statusCode != null ? ' (status: $statusCode)' : ''}',
        auth: (message) => 'AuthError: $message',
        validation: (message, fieldErrors) => 'ValidationError: $message',
        notFound: (message) => 'NotFound: $message',
        server: (message, statusCode) =>
            'ServerError: $message${statusCode != null ? ' (status: $statusCode)' : ''}',
        unknown: (message, exception) => 'UnknownError: $message',
      );
}
