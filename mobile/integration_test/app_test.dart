import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/projects/presentation/screens/projects_list_screen.dart';

/// Integration tests for DjVuFL Mobile app.
///
/// These tests verify end-to-end functionality across multiple screens and features.
void main() {
  testWidgets('App displays login screen when not authenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // The app should show the login screen initially
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });

  testWidgets('Login screen has email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify email field exists
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify login button exists
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Projects list screen has search bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override auth to simulate authenticated user
        ],
        child: const MaterialApp(
          home: ProjectsListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify search bar exists
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search projects...'), findsOneWidget);
  });

  testWidgets('App theme uses Material 3', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify MaterialApp is being used
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify Material 3 theme is configured
    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialApp?.theme?.useMaterial3, isTrue);
  });
}
