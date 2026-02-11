import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';
import 'app_theme.dart';

/// Theme notifier provider
///
/// Manages theme mode state and persists to SharedPreferences
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Theme state
class ThemeState {
  const ThemeState({required this.themeMode});

  final ThemeMode themeMode;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Theme notifier
///
/// Manages app theme and persists changes to storage
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    await StorageService.instance.init();
    final themeModeString = StorageService.instance.getThemeMode();
    if (themeModeString != null) {
      final themeModeEnum = ThemeModeEnum.fromString(themeModeString);
      state = themeModeEnum.toThemeMode();
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.instance.init();
    final themeModeEnum = ThemeModeEnum.values.firstWhere(
      (e) => e.toThemeMode() == mode,
    );
    await StorageService.instance.setThemeMode(themeModeEnum.value);
    state = mode;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Get current theme data based on mode and platform brightness
  ThemeData getThemeData(BuildContext context) {
    return switch (state) {
      ThemeMode.light => AppTheme.lightTheme,
      ThemeMode.dark => AppTheme.darkTheme,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme,
    };
  }

  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return switch (state) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
  }
}
