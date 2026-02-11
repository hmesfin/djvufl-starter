import '../models/auth_models.dart';

/// Authentication state
class AuthState {
  const AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isAuthenticated = false,
  });

  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isAuthenticated;

  AuthState copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
