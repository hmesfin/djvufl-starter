import 'failures.dart';

class AppException implements Exception {
  final AppFailure failure;
  final Object? exception;
  final StackTrace? stackTrace;

  const AppException({required this.failure, this.exception, this.stackTrace});

  @override
  String toString() {
    return 'AppException: ${failure.message}';
  }
}
