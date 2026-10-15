import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF8B2500); // Postal Terracotta Red
  static const Color primaryDark = Color(0xFF5C1800);
  static const Color primaryLight = Color(0xFFFBF4ED);

  static const Color accentAmber = Color(0xFFD97706); // Golden Wax Seal
  static const Color amberDark = Color(0xFF92400E);
  static const Color amberLight = Color(0xFFFEF3C7);

  static const Color parchmentBg = Color(0xFFFAF5EC); // Warm aged paper
  static const Color parchmentCard = Color(0xFFFFFDF9);
  static const Color parchmentBorder = Color(0xFFE5D5C0);

  static const Color inkNavy = Color(0xFF0F172A); // Traditional fountain ink
  static const Color inkMuted = Color(0xFF475569);
  static const Color inkSubtle = Color(0xFF94A3B8);

  static const Color postalGreen = Color(0xFF065F46);
  static const Color postalRed = Color(0xFF991B1B);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.hindSiliguriTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accentAmber,
        surface: parchmentBg,
        surfaceContainerLowest: parchmentCard,
        error: postalRed,
      ),
      scaffoldBackgroundColor: parchmentBg,
      appBarTheme: AppBarTheme(
        backgroundColor: parchmentCard,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.hindSiliguri(
          color: inkNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: inkNavy),
      ),
      cardTheme: CardThemeData(
        color: parchmentCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: parchmentBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.hindSiliguri(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.hindSiliguri(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: parchmentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: parchmentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: postalRed),
        ),
        hintStyle: GoogleFonts.hindSiliguri(
          color: inkSubtle,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.hindSiliguri(
          color: inkMuted,
          fontSize: 14,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.hindSiliguri(
          color: inkNavy,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.hindSiliguri(
          color: inkNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.hindSiliguri(
          color: inkNavy,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.hindSiliguri(
          color: inkNavy,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.hindSiliguri(
          color: inkMuted,
          fontSize: 14,
        ),
        labelSmall: GoogleFonts.hindSiliguri(
          color: inkSubtle,
          fontSize: 12,
        ),
      ),
    );
  }
}
