import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage keys
class StorageKeys {
  StorageKeys._();

  // Auth tokens (stored securely)
  static const String accessToken = '@auth/access_token';
  static const String refreshToken = '@auth/refresh_token';

  // Theme preference (stored in SharedPreferences)
  static const String themeMode = '@app/theme_mode';
  static const String onboardingComplete = '@app/onboarding_complete';
}

/// Storage service for managing app data
///
/// Uses:
/// - FlutterSecureStorage for sensitive data (auth tokens)
/// - SharedPreferences for app preferences (theme, onboarding, etc.)
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ==================== Secure Storage (Auth tokens) ====================

  /// Store access token securely
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: StorageKeys.accessToken);
  }

  /// Store refresh token securely
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: StorageKeys.refreshToken);
  }

  /// Clear all auth tokens
  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  // ==================== SharedPreferences ====================

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Store theme mode
  Future<void> setThemeMode(String themeMode) async {
    await prefs.setString(StorageKeys.themeMode, themeMode);
  }

  /// Get theme mode
  String? getThemeMode() {
    return prefs.getString(StorageKeys.themeMode);
  }

  /// Set onboarding complete
  Future<void> setOnboardingComplete(bool complete) async {
    await prefs.setBool(StorageKeys.onboardingComplete, complete);
  }

  /// Get onboarding complete status
  bool isOnboardingComplete() {
    return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
  }

  /// Generic methods for storing/retrieving data

  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  /// Remove a value by key
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  /// Clear all SharedPreferences (not secure storage)
  Future<void> clearAll() async {
    await prefs.clear();
  }
}
