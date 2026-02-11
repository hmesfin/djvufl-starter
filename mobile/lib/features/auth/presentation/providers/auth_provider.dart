import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/auth_models.dart';
import '../../data/models/auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';

/// Dio client provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthService(dioClient);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(
    dioClient: dioClient,
    authService: authService,
  );
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    try {
      await _repository.initialize();
      state = AsyncValue.data(_repository.state);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Login with email and password
  Future<void> login(LoginRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(request);
      state = AsyncValue.data(_repository.state);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Register a new user
  Future<void> register(UserRegistrationRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(request);
      state = AsyncValue.data(_repository.state);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Verify OTP code
  Future<void> verifyOTP(OtpVerificationRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.verifyOTP(request);
      state = AsyncValue.data(_repository.state);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Resend OTP code
  Future<void> resendOTP(String email) async {
    try {
      await _repository.resendOTP(email);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = AsyncValue.data(_repository.state);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(PasswordResetOtpRequest request) async {
    try {
      await _repository.requestPasswordReset(request);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset(PasswordResetOtpConfirmRequest request) async {
    try {
      await _repository.confirmPasswordReset(request);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.isAuthenticated ?? false;
});

/// Convenience provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.user;
});
