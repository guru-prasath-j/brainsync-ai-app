import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Deep Ocean Bioluminescence palette
  static const Color primary     = Color(0xFF00E5FF); // electric cyan
  static const Color secondary   = Color(0xFF00FF9F); // bioluminescent green
  static const Color accent      = Color(0xFF4D9FFF); // deep ocean blue
  static const Color bgDeep      = Color(0xFF000D1A); // ocean black
  static const Color bgMid       = Color(0xFF001428); // deep ocean
  static const Color bgSurface   = Color(0xFF001A35); // abyss surface
  static const Color silver      = Color(0xFFE2E8F0); // crisp white-silver
  static const Color glass       = Color(0x0F00E5FF); // cyan 6%
  static const Color glassBorder = Color(0x5000E5FF); // cyan 31%

  static const List<Color> gradient = [bgDeep, bgMid, bgSurface];

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        brightness: Brightness.dark,
        surface: bgSurface,
      ),
      scaffoldBackgroundColor: bgDeep,
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.4,
          fontFamily: 'SpaceGrotesk',
        ),
      ),
      cardTheme: CardThemeData(
        color: glass,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0A00E5FF), // cyan 4%
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        labelStyle: const TextStyle(color: Color(0xB3FFFFFF)),
        hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
        prefixIconColor: Color(0xB3FFFFFF),
        suffixIconColor: Color(0xB3FFFFFF),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: glass,
        side: const BorderSide(color: glassBorder),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      dividerTheme: const DividerThemeData(color: glassBorder, thickness: 1),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white70,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: glassBorder),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.white38,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
    );
  }

  // ── Light Ocean theme ──────────────────────────────────────────
  // Daytime ocean surface: bright azure with deep cyan accents
  static const Color lightPrimary    = Color(0xFF00789A); // dark cyan (AA on white)
  static const Color lightSecondary  = Color(0xFF00875A); // dark green (AA on white)
  static const Color lightAccent     = Color(0xFF005BB5); // ocean blue
  static const Color lightBg         = Color(0xFFF0FBFF); // light azure
  static const Color lightSurface    = Color(0xFFFFFFFF); // pure white
  static const Color lightOnSurface  = Color(0xFF0A1628); // deep navy text
  static const Color lightCardBorder = Color(0x3300789A); // cyan 20%

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimary,
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightAccent,
        brightness: Brightness.light,
        surface: lightSurface,
        onSurface: lightOnSurface,
      ),
      scaffoldBackgroundColor: lightBg,
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: lightOnSurface,
        displayColor: lightOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: lightOnSurface,
        shadowColor: Color(0x1400789A),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
          letterSpacing: 0.4,
          fontFamily: 'SpaceGrotesk',
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: const Color(0x1400789A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightCardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        labelStyle: TextStyle(color: lightOnSurface.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: lightOnSurface.withValues(alpha: 0.4)),
        prefixIconColor: Color.fromARGB(128, 10, 22, 40),
        suffixIconColor: Color.fromARGB(128, 10, 22, 40),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE8F8FF),
        side: const BorderSide(color: lightCardBorder),
        labelStyle: TextStyle(color: lightOnSurface, fontSize: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      iconTheme: IconThemeData(color: lightOnSurface.withValues(alpha: 0.7)),
      dividerTheme: const DividerThemeData(color: lightCardBorder, thickness: 1),
      listTileTheme: ListTileThemeData(
        textColor: lightOnSurface,
        iconColor: lightOnSurface.withValues(alpha: 0.6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightOnSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightCardBorder),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: lightPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lightPrimary : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? lightPrimary.withValues(alpha: 0.4)
              : Colors.black12,
        ),
      ),
    );
  }
}
