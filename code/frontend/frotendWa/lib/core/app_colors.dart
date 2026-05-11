import 'package:flutter/material.dart';

class AppColors {
  static const Color mintPrimary = Color(0xFF8EE596);
  static const Color blueSecondary = Color(0xFF5FD8E8);
  static const Color deepNavy = Color(0xFF242424);
  static const Color softBackground = Color(0xFFF8F8F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF242424);
  static const Color textSecondary = Color(0xFFA8A8A8);
  static const Color fieldBackground = Color(0xFFF3F3F3);
  static const Color faintText = Color(0xFFCFCFCF);

  static const Gradient primaryGradient = LinearGradient(
    colors: [mintPrimary, blueSecondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient splashGradient = LinearGradient(
    colors: [mintPrimary, blueSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}