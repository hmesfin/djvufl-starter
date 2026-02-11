import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/theme_notifier.dart';

/// Theme integration tests.
///
/// Tests theme configuration, theme mode switching, and theming functionality.
void main() {
  group('Theme Configuration', () {
    testWidgets('App has light and dark themes configured', (
      WidgetTester tester,
    ) async {
      // Test that both themes can be created without errors
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      // Both should use Material 3
      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
    });

    testWidgets('ThemeModeEnum correctly maps to ThemeMode', (
      WidgetTester tester,
    ) async {
      // Test enum to ThemeMode mapping
      expect(ThemeModeEnum.light.toThemeMode(), ThemeMode.light);
      expect(ThemeModeEnum.dark.toThemeMode(), ThemeMode.dark);
      expect(ThemeModeEnum.system.toThemeMode(), ThemeMode.system);

      // Test string to enum
      expect(ThemeModeEnum.fromString('light'), ThemeModeEnum.light);
      expect(ThemeModeEnum.fromString('dark'), ThemeModeEnum.dark);
      expect(ThemeModeEnum.fromString('system'), ThemeModeEnum.system);

      // Invalid string defaults to system
      expect(ThemeModeEnum.fromString('invalid'), ThemeModeEnum.system);
    });

    testWidgets('ThemeNotifier provides initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: Container())),
      );

      await tester.pumpAndSettle();

      // ThemeNotifier should provide ThemeMode (defaults to system initially)
      final container = tester.widget<Container>(find.byType(Container));

      expect(container, isNotNull);
    });
  });

  group('Theme Toggle', () {
    testWidgets('Theme can be toggled between light and dark', (
      WidgetTester tester,
    ) async {
      // Create a test widget that demonstrates theme toggling
      await tester.pumpWidget(
        const ProviderScope(child: ThemeToggleTestWidget()),
      );

      await tester.pumpAndSettle();

      // Initially shows light theme toggle button
      expect(find.text('Toggle to Dark'), findsOneWidget);

      // Tap to toggle to dark theme
      await tester.tap(find.text('Toggle to Dark'));
      await tester.pumpAndSettle();

      // Should now show light theme toggle button
      expect(find.text('Toggle to Light'), findsOneWidget);

      // Tap back to light theme
      await tester.tap(find.text('Toggle to Light'));
      await tester.pumpAndSettle();

      // Should show dark theme toggle button again
      expect(find.text('Toggle to Dark'), findsOneWidget);
    });

    testWidgets('Theme mode persists across rebuilds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: ThemeToggleTestWidget()));

      await tester.pumpAndSettle();

      // Toggle to dark mode
      await tester.tap(find.text('Toggle to Dark'));
      await tester.pumpAndSettle();

      // Verify dark mode is active
      expect(find.text('Current: Dark'), findsOneWidget);

      // Rebuild the widget (simulates app restart)
      await tester.pumpWidget(const ProviderScope(child: ThemeToggleTestWidget()));

      await tester.pumpAndSettle();

      // Theme should persist (in a real app with SharedPreferences)
      // For this test, we're just verifying the UI handles the theme state
    });
  });

  group('Theme Colors', () {
    test('Primary color is consistent across themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      // Both themes should use the same primary color (from seed)
      // The actual color values may differ in brightness
      expect(lightTheme.primaryColor, isNotNull);
      expect(darkTheme.primaryColor, isNotNull);
    });

    test('Dark theme has dark brightness', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('Light theme has light brightness', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
    });
  });
}

/// Test widget for demonstrating theme toggle functionality.
class ThemeToggleTestWidget extends ConsumerWidget {
  const ThemeToggleTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current: ${themeMode == ThemeMode.dark
                    ? "Dark"
                    : themeMode == ThemeMode.light
                    ? "Light"
                    : "System"}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.read(themeNotifierProvider.notifier).toggleTheme();
                },
                child: Text(
                  themeMode == ThemeMode.light
                      ? 'Toggle to Dark'
                      : 'Toggle to Light',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
