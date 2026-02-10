import 'package:flutter/material.dart';

class AppTheme {
  static const Color ebonyBlack = Color(0xFF1A1A1A); // Màu gỗ mun
  static const Color goldAccent = Color(0xFFC5A059); // Vàng đồng
  static const Color charcoal = Color(0xFF2C2C2C);

  static ThemeData get ebonyTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: ebonyBlack,
        centerTitle: true,
        titleTextStyle: TextStyle(color: goldAccent, fontSize: 20, letterSpacing: 2),
      ),
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: goldAccent,
      ),
    );
  }
}
