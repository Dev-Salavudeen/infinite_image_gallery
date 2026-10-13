import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const champagne = Color(0xFFC4A484);
  static const bronze = Color(0xFF8C6A4A);
  static const paper = Color(0xFFF4EFE8);
  static const ivory = Color(0xFFFFFBF6);
  static const ink = Color(0xFF1C1917);
  static const night = Color(0xFF0C0B0A);
  static const charcoal = Color(0xFF161412);

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: bronze,
      onPrimary: ivory,
      primaryContainer: Color(0xFFE8D5C4),
      onPrimaryContainer: ink,
      secondary: Color(0xFF5C534C),
      onSecondary: ivory,
      surface: ivory,
      onSurface: ink,
      onSurfaceVariant: Color(0xFF7A736C),
      outline: Color(0xFFDDD4C8),
      outlineVariant: Color(0xFFEDE6DC),
      surfaceContainerHighest: Color(0xFFE8E0D6),
      error: Color(0xFFB42318),
    );
    return _base(scheme, Brightness.light, paper);
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: champagne,
      onPrimary: night,
      primaryContainer: Color(0xFF3D2E22),
      onPrimaryContainer: Color(0xFFF3E6D6),
      secondary: Color(0xFFD4C4B0),
      onSecondary: night,
      surface: charcoal,
      onSurface: Color(0xFFF4EFE8),
      onSurfaceVariant: Color(0xFFA39B93),
      outline: Color(0xFF3A342E),
      outlineVariant: Color(0xFF2A2622),
      surfaceContainerHighest: Color(0xFF24211E),
      error: Color(0xFFFF6B5E),
    );
    return _base(scheme, Brightness.dark, night);
  }

  static ThemeData _base(ColorScheme scheme, Brightness brightness, Color scaffold) {
    final on = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;
    final text = GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displaySmall: GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.8,
        color: on,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.4,
        color: on,
      ),
      titleLarge: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: on,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: on,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: on,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.45,
        color: on,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.4,
        color: on,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.35,
        color: muted,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: on,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: muted,
      ),
    );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      canvasColor: scaffold,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffold,
        foregroundColor: on,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: on,
        ),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? charcoal : ivory,
        hintStyle: GoogleFonts.plusJakartaSans(color: muted, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? ivory : ink,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: isDark ? ink : ivory,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
