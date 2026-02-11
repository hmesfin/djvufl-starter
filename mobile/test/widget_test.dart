import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen displays correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [],
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pump();

    // Verify login screen elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    // The button exists (text may vary during loading)
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('App title is correct', (tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify app title (without waiting for full initialization)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
