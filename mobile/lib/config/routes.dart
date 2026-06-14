import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/projects/presentation/screens/projects_list_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/projects/presentation/screens/project_form_screen.dart';

/// Routes configuration
///
/// Auth-aware routing with go_router.
/// Unauthenticated users are redirected to /login.
/// Authenticated users are redirected to /.
class AppRoutes {
  AppRoutes._();

  // Route paths
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:uuid';
  static const String projectForm = '/projects/new';
  static const String projectEdit = '/projects/:uuid/edit';
  static const String profile = '/profile';

  // Route parameter keys
  static const String emailParam = 'email';
  static const String uuidParam = 'uuid';
}

/// Pure auth-redirect policy.
///
/// Extracted from the router so it can be unit-tested without a running app.
/// Returns the path to redirect to, or `null` to stay on [location].
String? authRedirect({
  required bool isAuthenticated,
  required String location,
}) {
  final isAuthRoute =
      location == AppRoutes.login ||
      location == AppRoutes.register ||
      location.startsWith(AppRoutes.otpVerification);

  // Unauthenticated users can only reach the auth screens.
  if (!isAuthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  // Authenticated users shouldn't sit on the auth screens.
  if (isAuthenticated && isAuthRoute) {
    return AppRoutes.home;
  }

  return null;
}

/// Bridges Riverpod auth-state changes into a [Listenable] that go_router can
/// use to re-evaluate its redirect — WITHOUT the GoRouter being recreated.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

/// Go Router provider
///
/// The router is built ONCE and lives for the app's lifetime. Auth-state
/// changes drive redirect re-evaluation via the router's `refreshListenable`
/// instead of rebuilding the whole GoRouter — the previous approach
/// (`ref.watch(authStateProvider)`) recreated the router on every auth change,
/// which reset navigation to the initial route and bounced authenticated users
/// out of deep screens.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Read (not watch) at evaluation time; refreshListenable drives re-eval.
      final isAuthenticated =
          ref.read(authStateProvider).value?.isAuthenticated ?? false;
      return authRedirect(
        isAuthenticated: isAuthenticated,
        location: state.matchedLocation,
      );
    },
    routes: [
      // Login route
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
        routes: [
          // Register route (nested under login for navigation)
          GoRoute(
            path: 'register',
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const RegisterScreen()),
          ),
        ],
      ),

      // Register route (standalone)
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),

      // OTP Verification route
      GoRoute(
        path: AppRoutes.otpVerification,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters[AppRoutes.emailParam] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: OTPVerificationScreen(email: email),
          );
        },
      ),

      // Home route - use ProjectsListScreen as home
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ProjectsListScreen()),
      ),

      // Projects route
      GoRoute(
        path: AppRoutes.projects,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const ProjectsListScreen()),
        routes: [
          // Project form route (create)
          GoRoute(
            path: 'new',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ProjectFormScreen(),
            ),
          ),
        ],
      ),

      // Project detail route
      GoRoute(
        path: AppRoutes.projectDetail,
        pageBuilder: (context, state) {
          final uuid = state.pathParameters[AppRoutes.uuidParam] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: ProjectDetailScreen(projectUuid: uuid),
          );
        },
        routes: [
          // Project form route (edit)
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) {
              final uuid = state.pathParameters[AppRoutes.uuidParam] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: ProjectFormScreen(projectUuid: uuid),
              );
            },
          ),
        ],
      ),

      // Profile route (placeholder)
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _ProfilePlaceholder(),
        ),
      ),
    ],
    errorBuilder: (context, state) => const _ErrorScreen(),
  );
});

/// Placeholder home screen (redirects to projects)
// ignore: unused_element
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DjVuFL Mobile')),
      body: Center(
        child: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(currentUserProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${user?.firstName ?? 'User'}!'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.projects),
                  child: const Text('View Projects'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).logout(),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Placeholder profile screen
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(currentUserProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user != null
                      ? '${user.firstName} ${user.lastName}'
                      : 'Not logged in',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).logout(),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Error screen
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
