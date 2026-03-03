import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color stockAlto = Color(0xFFDCFCE7); static const Color stockAltoText = Color(0xFF166534);
  static const Color stockMedio = Color(0xFFFEF9C3); static const Color stockMedioText = Color(0xFF854D0E);
  static const Color stockBajo = Color(0xFFFEE2E2); static const Color stockBajoText = Color(0xFF991B1B);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle caption = TextStyle(fontSize: 11, color: AppColors.textHint);
  static const TextStyle button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);
}
