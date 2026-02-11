import 'package:flutter/material.dart';

/// App theme configuration
///
/// Material Design 3 theme with light and dark modes
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Blue primary
        brightness: Brightness.light,
      ),
      // Customize colors here if needed
      // primaryColor: const Color(0xFF2196F3),
      // secondaryHeaderColor: const Color(0xFF03DAC6),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Blue primary
        brightness: Brightness.dark,
      ),
      // Customize colors here if needed
      // primaryColor: const Color(0xFFBB86FC),
      // secondaryHeaderColor: const Color(0xFF03DAC6),
    );
  }
}

/// Theme mode enum
enum ThemeModeEnum {
  light('light'),
  dark('dark'),
  system('system');

  const ThemeModeEnum(this.value);
  final String value;

  static ThemeModeEnum fromString(String value) {
    return ThemeModeEnum.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ThemeModeEnum.system,
    );
  }

  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }
}
