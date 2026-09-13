import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aqua_colors.dart';

class AquaTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AquaColors.deepNavy,
      colorScheme: const ColorScheme.dark(
        primary: AquaColors.cornflowerBlue,
        secondary: AquaColors.icyBlue,
        surface: AquaColors.surfaceNavy,
        error: AquaColors.statusPending,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AquaColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AquaColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AquaColors.textSecondary,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AquaColors.textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x283D518C),
        hintStyle: GoogleFonts.montserrat(
          color: AquaColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: AquaColors.icyBlue,
        suffixIconColor: AquaColors.icyBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AquaColors.glassBorderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AquaColors.glassBorderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AquaColors.cornflowerBlue, width: 1.5),
        ),
      ),
    );
  }
}
