import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'isDarkMode';
  static const String _emailKey = 'reportEmail';
  static const String _languageKey = 'language';
  static const String _fontScaleKey = 'fontScale';

  static SharedPreferences? _prefsInstance;
  static Future<SharedPreferences> get _prefs async => 
      _prefsInstance ??= await SharedPreferences.getInstance();

  // Initialize settings
  static Future<void> init() async {
    try {
      _prefsInstance = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  // Theme settings
  static Future<bool> isDarkMode() async {
    try {
      return (await _prefs).getBool(_themeKey) ?? false;
    } catch (e) {
      debugPrint('Error reading dark mode setting: $e');
      return false;
    }
  }

  static Future<void> setDarkMode(bool value) async {
    try {
      await (await _prefs).setBool(_themeKey, value);
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
  }

  // Email settings
  static Future<String?> getReportEmail() async {
    try {
      return (await _prefs).getString(_emailKey);
    } catch (e) {
      debugPrint('Error reading email setting: $e');
      return null;
    }
  }

  static Future<void> setReportEmail(String email) async {
    try {
      await (await _prefs).setString(_emailKey, email);
    } catch (e) {
      debugPrint('Error setting email: $e');
    }
  }

  // Language settings
  static Future<String> getLanguage() async {
    try {
      return (await _prefs).getString(_languageKey) ?? 'en';
    } catch (e) {
      debugPrint('Error reading language setting: $e');
      return 'en';
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    try {
      await (await _prefs).setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Font scale settings
  static Future<double> getFontScale() async {
    try {
      return (await _prefs).getDouble(_fontScaleKey) ?? 1.0;
    } catch (e) {
      debugPrint('Error reading font scale setting: $e');
      return 1.0;
    }
  }

  static Future<void> setFontScale(double scale) async {
    try {
      await (await _prefs).setDouble(_fontScaleKey, scale);
    } catch (e) {
      debugPrint('Error setting font scale: $e');
    }
  }

  // Brand Colors and Themes
  static const _brandColor = Color(0xFF2E7D32);
  
  static final _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _brandColor,
    brightness: Brightness.light,
  );

  static final _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _brandColor,
    brightness: Brightness.dark,
  );

  static ThemeData _getBaseTheme(ColorScheme colorScheme) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );
    
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: theme.cardTheme.copyWith(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          theme.textTheme.labelMedium,
        ),
        elevation: 3,
        height: 80,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
    );
  }

  static ThemeData getLightTheme() => _getBaseTheme(_lightColorScheme);
  
  static ThemeData getDarkTheme() => _getBaseTheme(_darkColorScheme);
}
