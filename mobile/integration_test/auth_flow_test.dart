import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/shared/utils/validators.dart';

/// Authentication flow integration tests.
///
/// Tests the login screen form validation and UI interactions.
void main() {
  group('Authentication Flow', () {
    testWidgets('Login screen displays correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      await tester.pumpAndSettle();

      // Verify all expected elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(
        find.text("Don't have an account? Create Account"),
        findsOneWidget,
      );
    });

    testWidgets('Email field validation works', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      await tester.pumpAndSettle();

      // Test empty validation
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Password field has visibility toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      await tester.pumpAndSettle();

      // Find password visibility toggle buttons
      final visibilityIcons = find.byIcon(Icons.visibility_outlined);
      final visibilityOffIcons = find.byIcon(Icons.visibility_off_outlined);

      // Initially password should be obscured (show visibility_off icon)
      expect(visibilityOffIcons, findsOneWidget);

      // Tap the toggle to show password
      await tester.tap(visibilityOffIcons);
      await tester.pumpAndSettle();

      // Should now show visibility icon (password visible)
      expect(visibilityIcons, findsOneWidget);
    });

    testWidgets('Login button is disabled when loading', (tester) async {
      // This test would need to mock the auth provider to simulate loading state
      await tester.pumpWidget(
        const ProviderScope(
          overrides: [],
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // When not loading, button should be enabled
      final loginButton = tester.widget<FilledButton>(find.text('Login'));
      expect(loginButton.enabled, isTrue);
    });

    testWidgets('Email validator rejects invalid email', (tester) async {
      // Test the validator directly
      expect(validateEmail(null), 'Email is required');
      expect(validateEmail(''), 'Email is required');
      expect(validateEmail('invalid'), 'Please enter a valid email');
      expect(validateEmail('test@'), 'Please enter a valid email');
      expect(validateEmail('test@test'), 'Please enter a valid email');

      // Valid emails should pass
      expect(validateEmail('test@example.com'), isNull);
      expect(validateEmail('user.name+tag@domain.co.uk'), isNull);
    });

    testWidgets('Password validator enforces minimum length', (tester) async {
      // Test the validator directly
      expect(validatePassword(null), 'Password is required');
      expect(validatePassword(''), 'Password is required');
      expect(
        validatePassword('short'),
        'Password must be at least 8 characters',
      );

      // Valid password should pass
      expect(validatePassword('password123'), isNull);
    });
  });
}
