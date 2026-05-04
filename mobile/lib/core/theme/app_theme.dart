import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // 1. BASE COLOR DEFINITIONS (Your Palette)
  // ==========================================
  
  // Dark Palette
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color bgDark = Color(0xFF121212);
  static const Color primaryDark = Color(0xFF64B5F6);
  static const Color surfaceDark = Color(0xFF1E1E1E); 

  // Light Palette
  static const Color textLight = Color(0xFF333333);
  static const Color bgLight = Color(0xFFFFFDF4);
  static const Color primaryLight = Color(0xFF0B3C6A);
  static const Color surfaceLight = Color(0xFFFFFFFF); 

  // Shared / Accents
  static const Color secondaryColor = Color(0xFFFF6B2C);
  static const Color accentColor = Color(0xFFFF9800);

  // Status / Semantic (Greens)
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color mainGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF388E3C);

  // Semantic (Errors)
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  // ==========================================
  // 2. TYPOGRAPHY (Google Fonts)
  // ==========================================
  
  // We create a helper method to apply Inter as the base font, 
  // and Montserrat as the heading font, adjusting colors based on the theme.
  static TextTheme _buildTextTheme(ThemeData baseTheme, Color bodyColor, Color titleColor) {
    return GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
      // Headings use Montserrat
      displayLarge: GoogleFonts.montserrat(
        textStyle: baseTheme.textTheme.displayLarge,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      displayMedium: GoogleFonts.montserrat(
        textStyle: baseTheme.textTheme.displayMedium,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      headlineMedium: GoogleFonts.montserrat(
        textStyle: baseTheme.textTheme.headlineMedium,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        textStyle: baseTheme.textTheme.titleLarge,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      // Body text explicitly set to Inter to ensure color mappings work
      bodyLarge: GoogleFonts.inter(color: bodyColor),
      bodyMedium: GoogleFonts.inter(color: bodyColor),
    );
  }

  // ==========================================
  // 3. LIGHT THEME SETUP
  // ==========================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      onPrimary: Colors.white, 
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      surface: surfaceLight,
      onSurface: textLight, 
      error: errorLight,
      onError: Colors.white,
    ),
    // Call the font helper here
    textTheme: _buildTextTheme(ThemeData.light(), textLight, primaryLight),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgLight,
      foregroundColor: primaryLight, 
      elevation: 0,
    ),
  );

  // ==========================================
  // 4. DARK THEME SETUP
  // ==========================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: bgDark, 
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      surface: surfaceDark,
      onSurface: textDark, 
      error: errorDark,
      onError: Colors.black,
    ),
    // Call the font helper here
    textTheme: _buildTextTheme(ThemeData.dark(), textDark, primaryDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: primaryDark,
      elevation: 0,
    ),
  );
}