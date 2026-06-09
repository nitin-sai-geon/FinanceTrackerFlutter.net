import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFF9F9F9),
      onSurface: Color(0xFF1B1B1B),
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF5D5E60),
      onSecondary: Color(0xFFFFFFFF),
      outline: Color(0xFFE2E2E4),
      outlineVariant: Color(0xFFE2E2E4),
      surfaceContainer: Color(0xFFEEEEEE),
    ),
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF9F9F9),
      foregroundColor: Color(0xFF1B1B1B),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF131315),
      onSurface: Color(0xFFE5E1E4),
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF2F3131),
      secondary: Color(0xFFC6C6CF),
      onSecondary: Color(0xFF2F3037),
      outline: Color(0xFF8E9192),
      outlineVariant: Color(0xFF444748),
      surfaceContainer: Color(0xFF201F22),
      surfaceContainerLowest: Color(0xFF0E0E10),
      surfaceContainerHighest: Color(0xFF353437),
    ),
    scaffoldBackgroundColor: const Color(0xFF131315),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131315),
      foregroundColor: Color(0xFFE5E1E4),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
