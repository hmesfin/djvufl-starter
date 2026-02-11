import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/failures.dart';
import '../../config/api.dart';

/// Dio instance for API calls
///
/// Configured with:
/// - Base URL (ngrok or platform-specific for development)
/// - Timeout (30 seconds)
/// - Request interceptor (adds JWT token from secure storage)
/// - Response interceptor (handles 401 errors)
class DioClient {
  DioClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.getApiBaseUrl(),
        connectTimeout: ApiConfig.apiTimeout,
        receiveTimeout: ApiConfig.apiTimeout,
        sendTimeout: ApiConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Request interceptor: Add JWT token from secure storage to all requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _secureStorage.read(
              key: ApiConfig.accessTokenKey,
            );

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (error) {
            // Silently fail if we can't get the token
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          // If unauthorized, clear the stored token
          if (error.response?.statusCode == 401) {
            try {
              await _secureStorage.delete(key: ApiConfig.accessTokenKey);
            } catch (storageError) {
              // Silently fail if we can't clear the token
            }
          }

          // Convert Dio error to AppFailure
          final failure = _handleDioError(error);
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: AppException(failure),
            type: error.type,
          ));
        },
      ),
    );
  }

  AppFailure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppFailure.network(message: 'Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AppFailure.network(message: 'No internet connection. Please check your network.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          if (data is Map && data.containsKey('detail')) {
            return AppFailure.validation(message: data['detail'].toString());
          }
          return const AppFailure.validation(message: 'Invalid request data');

        case 401:
          return const AppFailure.auth(message: 'Authentication failed. Please log in again.');

        case 403:
          return const AppFailure.auth(message: 'You do not have permission to perform this action.');

        case 404:
          return const AppFailure.notFound(message: 'The requested resource was not found.');

        case 422:
          if (data is Map) {
            final fieldErrors = <String, String>{};
            if (data.containsKey('detail')) {
              return AppFailure.validation(message: data['detail'].toString());
            }
            // Extract field errors
            data.forEach((key, value) {
              if (key != 'detail' && value is List) {
                fieldErrors[key] = value.join(', ');
              }
            });
            return AppFailure.validation(
              message: 'Please correct the errors and try again.',
              fieldErrors: fieldErrors,
            );
          }
          return const AppFailure.validation(message: 'Validation error');

        case 500:
        case 502:
        case 503:
        case 504:
          return AppFailure.server(
            message: 'Server error. Please try again later.',
            statusCode: statusCode,
          );

        default:
          return AppFailure.network(
            message: data?['detail']?.toString() ?? 'An error occurred',
            statusCode: statusCode,
          );
      }
    }

    return AppFailure.unknown(
      message: error.message ?? 'An unknown error occurred',
      exception: error.error,
    );
  }

  /// Set the authentication token
  Future<void> setAuthToken(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _secureStorage.write(key: ApiConfig.accessTokenKey, value: token);
    } catch (error) {
      throw const AppException(AppFailure.unknown(message: 'Failed to set auth token'));
    }
  }

  /// Clear the authentication token
  Future<void> clearAuthToken() async {
    try {
      _dio.options.headers.remove('Authorization');
      await _secureStorage.delete(key: ApiConfig.accessTokenKey);
    } catch (error) {
      throw const AppException(AppFailure.unknown(message: 'Failed to clear auth token'));
    }
  }

  /// Get the current authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: ApiConfig.accessTokenKey);
    } catch (error) {
      return null;
    }
  }
}
