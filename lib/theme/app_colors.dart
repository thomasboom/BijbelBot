import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // M3 Expressive seed color - neutral blue for spiritual/biblical app
  // Using a more neutral blue that avoids purple tones in dynamic generation
  static const Color seedColor = Color(0xFF1976D2);

  // Additional app-specific colors can be added here
  static const Color primary = seedColor;
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}
