import 'package:flutter/material.dart';

abstract final class AppColors {
  static const backgroundDark = Color(0xFF0B1020);
  static const surfaceDark = Color(0xFF141B2D);
  static const surfaceAltDark = Color(0xFF1D263D);
  static const blue = Color(0xFF3B82F6);
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFF59E0B);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: brightness,
    surface: dark ? AppColors.surfaceDark : Colors.white,
    error: const Color(0xFFEF4444),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? AppColors.backgroundDark
        : const Color(0xFFF6F7FB),
    fontFamily: 'sans-serif',
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.surfaceAltDark : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
      indicatorColor: AppColors.blue.withValues(alpha: .18),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
      indicatorColor: AppColors.blue.withValues(alpha: .18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
