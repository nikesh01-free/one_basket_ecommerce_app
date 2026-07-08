import 'package:flutter/material.dart';

abstract class OBColors {
  // Primary Scale (OneBasket Indigo - Trust)
  static const Color primary50 = Color(0xFFF5F6FF);
  static const Color primary100 = Color(0xFFE0E4FF);
  static const Color primary200 = Color(0xFFC1C9FF);
  static const Color primary300 = Color(0xFF9AA4FC);
  static const Color primary400 = Color(0xFF707AEB);
  static const Color primary500 = Color(0xFF4F46E5); // Base Brand Primary
  static const Color primary600 = Color(0xFF4338CA);
  static const Color primary700 = Color(0xFF3730A3);
  static const Color primary800 = Color(0xFF1E1B4B);
  static const Color primary900 = Color(0xFF0F0E2E);

  // Neutral Scale (OneBasket Warm Gray - Freshness & Local Feel)
  static const Color neutral50 = Color(0xFFFAF9F6); // Light Background
  static const Color neutral100 = Color(0xFFF5F4F0); // Light Surface
  static const Color neutral200 = Color(0xFFEAE8E2); // Neomorphic dark shadow, dividers
  static const Color neutral300 = Color(0xFFD7D4CD); // Disabled button bg, borders
  static const Color neutral400 = Color(0xFFAFA99F); // Placeholder text, inactive icons
  static const Color neutral500 = Color(0xFF877F73); // Secondary labels, captions
  static const Color neutral600 = Color(0xFF625A50); // Secondary body text
  static const Color neutral700 = Color(0xFF453E36); // Light Primary Text
  static const Color neutral800 = Color(0xFF2C2722); // Headings
  static const Color neutral900 = Color(0xFF1C1917); // Dark Background / Deep Text

  // Dark Mode Surfaces
  static const Color surfaceDark50 = Color(0xFF121212); // App background (alternative to neutral-900)
  static const Color surfaceDark100 = Color(0xFF1C1C1E); // Card surface
  static const Color surfaceDark200 = Color(0xFF242426); // Elevated card
  static const Color surfaceDark300 = Color(0xFF2C2C2E); // Input field fill
  static const Color surfaceDark400 = Color(0xFF3A3A3C); // Divider
  static const Color surfaceDark500 = Color(0xFF48484A); // Border

  // Semantic Light
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoBg = Color(0xFFE3F2FD);

  // Semantic Dark
  static const Color successDark = Color(0xFF4CAF50);
  static const Color warningDark = Color(0xFFFF9800);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color infoDark = Color(0xFF42A5F5);
}
