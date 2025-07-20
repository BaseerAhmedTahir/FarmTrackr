import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.green.shade600,
      secondary: Colors.teal.shade600,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(size: 28, opacity: 1.0),
      unselectedIconTheme: IconThemeData(size: 24, opacity: 0.8),
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.green.shade400,
      secondary: Colors.teal.shade400,
      surface: Colors.grey.shade900,
      onSurface: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(size: 28, opacity: 1.0),
      unselectedIconTheme: IconThemeData(size: 24, opacity: 0.8),
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
