import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Vazir', // Vazir برای فارسی، fallback به سیستم برای انگلیسی
    textTheme: const TextTheme(
      // می‌تونی customize کنی
    ),
    // Material 3 اگر می‌خوای
    useMaterial3: true,
  );
}