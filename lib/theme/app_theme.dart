import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light, const Color(0xFF2563EB));
  static ThemeData dark() => _build(Brightness.dark, const Color(0xFF60A5FA));

  static ThemeData _build(Brightness brightness, Color seed) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    );
    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
