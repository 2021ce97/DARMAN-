import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, AppColors.textPrimary, AppColors.textSecondary, AppColors.textHint);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: _appBarTheme(AppColors.surface, AppColors.textPrimary),
      bottomNavigationBarTheme: _bottomNavTheme(AppColors.surface),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(AppColors.surface, AppColors.outline),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF0F1117);
    const darkSurface = Color(0xFF1A1D27);
    const darkSurfaceVariant = Color(0xFF252836);
    const darkOutline = Color(0xFF2E3347);
    const darkTextPrimary = Color(0xFFF0F2F8);
    const darkTextSecondary = Color(0xFFB0B8D0);
    const darkTextHint = Color(0xFF6B7494);

    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, darkTextPrimary, darkTextSecondary, darkTextHint);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: textTheme,
      appBarTheme: _appBarTheme(darkSurface, darkTextPrimary),
      bottomNavigationBarTheme: _bottomNavTheme(darkSurface),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(darkSurface, darkOutline),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500, color: darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary, Color hint) {
    return GoogleFonts.manropeTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: primary, height: 1.2),
      headlineMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: primary, height: 1.3),
      headlineSmall: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      titleLarge: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      bodySmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w400, color: hint, height: 1.4),
      labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500, color: hint),
    );
  }

  static AppBarTheme _appBarTheme(Color bg, Color fg) => AppBarTheme(
    backgroundColor: bg,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: fg),
    iconTheme: IconThemeData(color: fg),
    surfaceTintColor: Colors.transparent,
  );

  static BottomNavigationBarThemeData _bottomNavTheme(Color bg) =>
      BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF9E9E9E),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      );

  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: 0,
      textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme() => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _inputDecorationTheme(Color fill, Color outline) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF9E9E9E)),
      );
}
