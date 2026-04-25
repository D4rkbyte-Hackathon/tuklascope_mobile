import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // 1. BASE COLOR DEFINITIONS (Your Palette)
  // ==========================================
  
  // Dark Palette
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color bgDark = Color(0xFF121212);
  static const Color primaryDark = Color(0xFF64B5F6);
  static const Color surfaceDark = Color(0xFF1E1E1E); // Added: For cards/dialogs in dark mode

  // Light Palette
  static const Color textLight = Color(0xFF333333);
  static const Color bgLight = Color(0xFFFFFDF4);
  static const Color primaryLight = Color(0xFF0B3C6A);
  static const Color surfaceLight = Color(0xFFFFFFFF); // Added: For cards/dialogs in light mode

  // Shared / Accents
  static const Color secondaryColor = Color(0xFFFF6B2C);
  static const Color accentColor = Color(0xFFFF9800);

  // Status / Semantic (Greens)
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color mainGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF388E3C);

  // Semantic (Errors - Added for completeness)
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  // ==========================================
  // 2. LIGHT THEME SETUP
  // ==========================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      onPrimary: Colors.white, // Text on primary buttons
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      surface: surfaceLight,
      onSurface: textLight, // Default text color
      error: errorLight,
      onError: Colors.white,
    ),
    // Setting default text styles so you don't have to hardcode colors everywhere
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: textLight),
      titleLarge: TextStyle(color: primaryLight, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgLight,
      foregroundColor: primaryLight, // Icon/Text colors on appbar
      elevation: 0,
    ),
  );

  // ==========================================
  // 3. DARK THEME SETUP
  // ==========================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: bgDark, // Dark text on light blue primary buttons
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      surface: surfaceDark,
      onSurface: textDark, // Default text color
      error: errorDark,
      onError: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textDark),
      titleLarge: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: primaryDark,
      elevation: 0,
    ),
  );
}