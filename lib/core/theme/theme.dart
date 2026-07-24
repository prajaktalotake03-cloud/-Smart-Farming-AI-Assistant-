import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color emeraldGreen = Color(0xFF0F9D58);
  static const Color forestDark = Color(0xFF0B1B11);
  static const Color mintLight = Color(0xFFE8F5E9);
  static const Color soilAmber = Color(0xFFD84315);
  static const Color sunYellow = Color(0xFFFFB300);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emeraldGreen,
        brightness: Brightness.light,
        primary: emeraldGreen,
        onPrimary: Colors.white,
        secondary: soilAmber,
        onSecondary: Colors.white,
        tertiary: sunYellow,
        background: const Color(0xFFF7FBF7),
        surface: Colors.white,
        onBackground: const Color(0xFF1A1C19),
        onSurface: const Color(0xFF1A1C19),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24),
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
        titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1C19),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1C19)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emeraldGreen,
        brightness: Brightness.dark,
        primary: emeraldGreen,
        onPrimary: Colors.white,
        secondary: soilAmber,
        onSecondary: Colors.white,
        tertiary: sunYellow,
        background: forestDark,
        surface: const Color(0xFF13251A),
        onBackground: const Color(0xFFE2E3DD),
        onSurface: const Color(0xFFE2E3DD),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24),
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
        titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        color: const Color(0xFF13251A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFE2E3DD),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFFE2E3DD)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A140E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
