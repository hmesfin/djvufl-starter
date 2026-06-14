import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/config/routes.dart';

/// Unit tests for the pure auth-redirect policy.
///
/// These pin the navigation rules independently of go_router/Riverpod wiring.
/// The key regression guarded here: an authenticated user on a deep route must
/// STAY there (return null) — the old "recreate the router on every auth change"
/// pattern reset navigation to the initial route and bounced such users to home.
void main() {
  group('authRedirect', () {
    test('unauthenticated user on a protected route -> /login', () {
      expect(
        authRedirect(isAuthenticated: false, location: AppRoutes.projects),
        AppRoutes.login,
      );
      expect(
        authRedirect(isAuthenticated: false, location: '/projects/abc-123'),
        AppRoutes.login,
      );
    });

    test('unauthenticated user on an auth route stays put', () {
      expect(
        authRedirect(isAuthenticated: false, location: AppRoutes.login),
        isNull,
      );
      expect(
        authRedirect(isAuthenticated: false, location: AppRoutes.register),
        isNull,
      );
      expect(
        authRedirect(
          isAuthenticated: false,
          location: '${AppRoutes.otpVerification}?email=a@b.com',
        ),
        isNull,
      );
    });

    test('authenticated user on an auth route -> home', () {
      expect(
        authRedirect(isAuthenticated: true, location: AppRoutes.login),
        AppRoutes.home,
      );
      expect(
        authRedirect(isAuthenticated: true, location: AppRoutes.register),
        AppRoutes.home,
      );
    });

    test('authenticated user on a deep route STAYS (no bounce to home)', () {
      expect(
        authRedirect(isAuthenticated: true, location: '/projects/abc-123'),
        isNull,
      );
      expect(
        authRedirect(isAuthenticated: true, location: AppRoutes.home),
        isNull,
      );
      expect(
        authRedirect(isAuthenticated: true, location: AppRoutes.profile),
        isNull,
      );
    });
  });
}
