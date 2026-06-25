import 'package:flutter/material.dart';

class AppTheme {
  // Light palette
  static const Color _lSurface = Color(0xFFF9F9F9);
  static const Color _lOnSurface = Color(0xFF1B1B1B);
  static const Color _lPrimary = Color(0xFF000000);
  static const Color _lOnPrimary = Color(0xFFFFFFFF);
  static const Color _lSecondary = Color(0xFF5D5E60);
  static const Color _lOutline = Color(0xFFE2E2E4);
  static const Color _lSurfaceContainer = Color(0xFFEEEEEE);
  static const Color _lMuted = Color(0xFF838485);

  // Dark palette
  static const Color _dSurface = Color(0xFF131315);
  static const Color _dOnSurface = Color(0xFFE5E1E4);
  static const Color _dPrimary = Color(0xFFFFFFFF);
  static const Color _dOnPrimary = Color(0xFF2F3131);
  static const Color _dSecondary = Color(0xFFC6C6CF);
  static const Color _dOnSecondary = Color(0xFF2F3037);
  static const Color _dOutline = Color(0xFF8E9192);
  static const Color _dOutlineVariant = Color(0xFF444748);
  static const Color _dSurfaceContainer = Color(0xFF201F22);
  static const Color _dSurfaceContainerLowest = Color(0xFF0E0E10);
  static const Color _dSurfaceContainerHighest = Color(0xFF353437);
  static const Color _dMuted = Color(0xFFC4C7C8);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: _lSurface,
      onSurface: _lOnSurface,
      primary: _lPrimary,
      onPrimary: _lOnPrimary,
      secondary: _lSecondary,
      onSecondary: _lOnPrimary,
      tertiary: _lMuted,
      outline: _lOutline,
      outlineVariant: _lOutline,
      surfaceContainer: _lSurfaceContainer,
    ),
    scaffoldBackgroundColor: _lSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lSurface,
      foregroundColor: _lOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _lOnSurface,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _lOnSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: _lOnSurface),
      bodyMedium: TextStyle(fontSize: 14, color: _lMuted),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _lSecondary,
        letterSpacing: 0.8,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _lOutline),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _lPrimary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lPrimary,
        foregroundColor: _lOnPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _lOutline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lSurface,
      selectedItemColor: _lPrimary,
      unselectedItemColor: _lSecondary,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lPrimary,
      foregroundColor: _lOnPrimary,
    ),
    dividerTheme: const DividerThemeData(color: _lOutline),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? _lPrimary : null,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: _dSurface,
      onSurface: _dOnSurface,
      primary: _dPrimary,
      onPrimary: _dOnPrimary,
      secondary: _dSecondary,
      onSecondary: _dOnSecondary,
      tertiary: _dMuted,
      outline: _dOutline,
      outlineVariant: _dOutlineVariant,
      surfaceContainer: _dSurfaceContainer,
      surfaceContainerLowest: _dSurfaceContainerLowest,
      surfaceContainerHighest: _dSurfaceContainerHighest,
    ),
    scaffoldBackgroundColor: _dSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: _dSurface,
      foregroundColor: _dOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _dOnSurface,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _dOnSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: _dOnSurface),
      bodyMedium: TextStyle(fontSize: 14, color: _dMuted),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _dSecondary,
        letterSpacing: 0.8,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _dOutlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _dPrimary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _dPrimary,
        foregroundColor: _dOnPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _dOutlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _dSurface,
      selectedItemColor: _dPrimary,
      unselectedItemColor: _dSecondary,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _dPrimary,
      foregroundColor: _dOnPrimary,
    ),
    dividerTheme: const DividerThemeData(color: _dOutlineVariant),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? _dPrimary : null,
      ),
    ),
  );
}
