import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class GamePalette {
  static const ink = Color(0xFF0F172A);
  static const panel = Color(0xFF1E293B);
  static const panelRaised = Color(0xFF263449);
  static const gold = Color(0xFFF59E0B);
  static const emerald = Color(0xFF10B981);
  static const muted = Color(0xFF94A3B8);
  static const danger = Color(0xFFEF4444);
  static const line = Color(0xFF334155);
}

abstract final class GameTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GamePalette.ink,
      colorScheme: const ColorScheme.dark(
        primary: GamePalette.gold,
        secondary: GamePalette.emerald,
        surface: GamePalette.panel,
        error: GamePalette.danger,
      ),
    );

    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.oswald(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.4,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.oswald(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.oswald(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: GamePalette.ink,
      appBarTheme: AppBarTheme(
        backgroundColor: GamePalette.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: GamePalette.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: GamePalette.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GamePalette.gold,
          foregroundColor: GamePalette.ink,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
