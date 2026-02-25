import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get ebonyTheme {
    return ThemeData(
      primaryColor: AppColors.ebonyDark,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,

      // AppBar chuẩn Luxury
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Định nghĩa Font chữ mặc định
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.w900, fontSize: 32),
        headlineMedium: TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        titleLarge: TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.bold, fontSize: 18),
        bodyLarge: TextStyle(color: AppColors.ebonyMedium, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: AppColors.ebonyMedium, fontSize: 14),
      ),

      // Nút bấm chính
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ebonyDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14),
        ),
      ),

      // Thẻ hiển thị (Card) - FIX LỖI ÉP KIỂU TẠI ĐÂY
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // Màu sắc phụ trợ - FIX DEPRECATED BACKGROUND
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.woodAccent,
        primary: AppColors.ebonyDark,
        secondary: AppColors.woodAccent,
        surface: AppColors.background,
      ),
    );
  }
}
