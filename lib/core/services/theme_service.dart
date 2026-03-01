import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'theme_mode';

/// Manages app theme mode (system, light, dark) with persistence.
class ThemeService {
  ThemeService._();
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  bool _initialized = false;

  /// Call once at app startup. Loads saved preference and sets [themeMode].
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModeKey);
    themeMode.value = _themeModeFromString(saved) ?? ThemeMode.system;
  }

  /// Set theme mode and persist to disk.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _stringFromThemeMode(mode));
  }

  static ThemeMode? _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _stringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
