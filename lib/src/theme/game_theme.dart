import 'package:flutter/material.dart';

abstract final class GamePalette {
  static const ink = Color(0xFF080D12);
  static const panel = Color(0xFF111A22);
  static const panelRaised = Color(0xFF182630);
  static const gold = Color(0xFFE7BD68);
  static const emerald = Color(0xFF49D6A1);
  static const muted = Color(0xFF91A2AE);
  static const danger = Color(0xFFFF6E78);
  static const line = Color(0xFF263640);
}

abstract final class GameTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: GamePalette.ink,
    colorScheme: const ColorScheme.dark(
      primary: GamePalette.gold,
      secondary: GamePalette.emerald,
      surface: GamePalette.panel,
      error: GamePalette.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GamePalette.ink,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
