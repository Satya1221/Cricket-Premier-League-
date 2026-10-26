import 'package:flutter/material.dart';

/// Semantic design tokens shared by every screen. Avoid page-specific hex
/// literals; use these roles so colour meaning stays stable across the app.
abstract final class AppColors {
  static const background = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceRaised = Color(0xFF263449);
  static const border = Color(0xFF334155);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFF64748B);

  /// Action/selection only. Do not use this colour for money or low stats.
  static const action = Color(0xFFF59E0B);
  static const positive = Color(0xFF10B981);
  static const negative = Color(0xFFEF4444);
  static const neutral = Color(0xFFCBD5E1);
}

abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;
}

/// The app-wide type ramp. Font families are supplied by GameTheme.
abstract final class AppType {
  static const display = TextStyle(fontSize: 40, fontWeight: FontWeight.w800, height: 1.05);
  static const title = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.15);
  static const heading = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.25);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.4);
  static const micro = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.4);
}
