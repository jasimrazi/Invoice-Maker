import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF0077B6); // Blue
  static const Color accentColor = Color(0xFF90E0EF); // Light Blue
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color textColor = Color(0xFF03045E); // Dark Gray
  static const Color borderColor = Color(0xFFB0BEC5); // Light Gray for borders
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF28282B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textColor),
        bodyMedium: TextStyle(color: AppColors.textColor),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        labelStyle: TextStyle(color: AppColors.textColor),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor, // Set FAB color
        foregroundColor: Colors.white, // Set icon color inside FAB
        elevation: 4.0, // Optional: Add elevation for a shadow effect
      ),
    );
  }
}
