import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aqua_colors.dart';

class AquaTheme {
  static ThemeData get lightTheme {
    final base = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AquaColors.iceBlue,
      colorScheme: const ColorScheme.light(
        primary: AquaColors.turquoise,
        secondary: AquaColors.slateBlue,
        surface: AquaColors.glacier,
        error: AquaColors.statusError,
        onPrimary: AquaColors.textOnDark,
        onSecondary: AquaColors.textOnDark,
        onSurface: AquaColors.textPrimary,
        onError: AquaColors.textOnDark,
      ),
      textTheme: base.copyWith(
        // Display
        displayLarge: GoogleFonts.montserrat(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AquaColors.textPrimary,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AquaColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AquaColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        // Heading
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AquaColors.textPrimary,
          letterSpacing: -0.2,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
        ),
        // Title
        titleLarge: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
          letterSpacing: 0.1,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AquaColors.textSecondary,
          letterSpacing: 0.1,
        ),
        // Body
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AquaColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AquaColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AquaColors.textMuted,
          height: 1.4,
        ),
        // Label
        labelLarge: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AquaColors.textPrimary,
          letterSpacing: 0.3,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AquaColors.textSecondary,
          letterSpacing: 0.4,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AquaColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AquaColors.glassSurface,
        hintStyle: GoogleFonts.montserrat(
          color: AquaColors.textMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.montserrat(
          color: AquaColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.montserrat(
          color: AquaColors.turquoise,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AquaColors.slateBlue,
        suffixIconColor: AquaColors.slateBlue,
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
          borderSide: const BorderSide(color: AquaColors.turquoise, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AquaColors.statusError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AquaColors.statusError, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AquaColors.platinum,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AquaColors.textPrimary),
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AquaColors.textPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AquaColors.glassSurface,
        selectedColor: AquaColors.turquoise,
        disabledColor: AquaColors.platinum,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          color: AquaColors.textSecondary,
        ),
        side: const BorderSide(color: AquaColors.glassBorderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AquaColors.iceBlue,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AquaColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: AquaColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AquaColors.textPrimary,
        contentTextStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AquaColors.turquoise,
        circularTrackColor: AquaColors.glacier,
        linearTrackColor: AquaColors.glacier,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Alias para compatibilidad hacia atrás
  static ThemeData get darkTheme => lightTheme;
}
