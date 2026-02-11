import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/auth_models.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

/// Authentication Repository
///
/// Manages authentication state and coordinates between the service and storage.
/// Equivalent to React Native's Zustand auth store.
class AuthRepository {
  AuthRepository({
    required DioClient dioClient,
    required AuthService authService,
  })  : _dioClient = dioClient,
        _authService = authService;

  final DioClient _dioClient;
  final AuthService _authService;

  AuthState _state = const AuthState();

  /// Get current auth state
  AuthState get state => _state;

  /// Initialize auth state from storage
  Future<void> initialize() async {
    await StorageService.instance.init();

    final accessToken = await StorageService.instance.getAccessToken();
    final refreshToken = await StorageService.instance.getRefreshToken();

    if (accessToken != null) {
      _state = _state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isAuthenticated: true,
      );

      // Try to fetch current user data
      try {
        final user = await _authService.getMe();
        _state = _state.copyWith(user: user);
      } catch (e) {
        // Token might be expired, clear state
        await logout();
      }
    }
  }

  /// Set JWT tokens (also updates API client)
  Future<void> setTokens(AuthResponse tokens) async {
    await _dioClient.setAuthToken(tokens.access);
    await StorageService.instance.setAccessToken(tokens.access);
    await StorageService.instance.setRefreshToken(tokens.refresh);

    _state = _state.copyWith(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
      isAuthenticated: true,
    );
  }

  /// Set user data
  void setUser(UserModel user) {
    _state = _state.copyWith(user: user);
  }

  /// Login with email and password
  Future<UserModel> login(LoginRequest request) async {
    final tokens = await _authService.login(request);
    await setTokens(tokens);

    // Fetch user data after successful login
    final user = await _authService.getMe();
    _state = _state.copyWith(user: user);

    return user;
  }

  /// Register a new user
  Future<void> register(UserRegistrationRequest request) async {
    await _authService.register(request);
  }

  /// Verify OTP code
  Future<void> verifyOTP(OtpVerificationRequest request) async {
    await _authService.verifyOTP(request);
  }

  /// Resend OTP code
  Future<void> resendOTP(String email) async {
    await _authService.resendOTP(email);
  }

  /// Logout and clear all auth state
  Future<void> logout() async {
    await _dioClient.clearAuthToken();
    await StorageService.instance.clearAuthTokens();

    _state = const AuthState();
  }

  /// Request password reset OTP
  Future<void> requestPasswordReset(PasswordResetOtpRequest request) async {
    await _authService.requestPasswordResetOTP(request);
  }

  /// Confirm password reset with OTP
  Future<void> confirmPasswordReset(PasswordResetOtpConfirmRequest request) async {
    await _authService.confirmPasswordResetOTP(request);
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    final refreshToken = _state.refreshToken;
    if (refreshToken == null) {
      return false;
    }

    try {
      final tokens = await _authService.refreshToken(refreshToken);
      await setTokens(tokens);
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }
}
