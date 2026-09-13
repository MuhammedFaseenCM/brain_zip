import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ink & Ember — cool stone surfaces, ember path accent, slate type.
abstract final class ZipColors {
  static const ink = Color(0xFF0F172A);
  static const inkSoft = Color(0xFF334155);
  static const mist = Color(0xFFE8EEF5);
  static const mistDeep = Color(0xFFD5DEEA);
  static const paper = Color(0xFFF7F9FC);
  static const ember = Color(0xFFFF6B2C);
  static const emberDeep = Color(0xFFE85A1C);
  static const emberSoft = Color(0xFFFFD8C2);
  static const success = Color(0xFF0D9488);
  static const successSoft = Color(0xFFCCFBF1);
  static const wall = Color(0xFF1E293B);
  static const number = Color(0xFFBE123C);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ZipColors.mist,
  );

  final textTheme = GoogleFonts.lexendTextTheme(base.textTheme).apply(
    bodyColor: ZipColors.ink,
    displayColor: ZipColors.ink,
  );

  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: ZipColors.ember,
      onPrimary: Colors.white,
      primaryContainer: ZipColors.emberSoft,
      onPrimaryContainer: ZipColors.emberDeep,
      secondary: ZipColors.ink,
      onSecondary: Colors.white,
      tertiary: ZipColors.success,
      onTertiary: Colors.white,
      surface: ZipColors.paper,
      onSurface: ZipColors.ink,
      onSurfaceVariant: ZipColors.inkSoft,
      outline: Color(0xFF94A3B8),
      outlineVariant: Color(0xFFCBD5E1),
      error: Color(0xFFDC2626),
    ),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: ZipColors.ink,
      titleTextStyle: GoogleFonts.lexend(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: ZipColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: ZipColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZipColors.ember,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ZipColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ZipColors.inkSoft,
        textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ZipColors.ember,
      linearTrackColor: ZipColors.mistDeep,
    ),
  );
}
