import 'package:flutter/material.dart';

abstract class OBShadows {
  static List<BoxShadow> neomorphic({
    required int level,
    required bool isDarkMode,
    bool pressed = false,
  }) {
    if (level == 0) return const [];

    final double offsetVal = switch (level) {
      1 => 2.0,
      2 => 3.0,
      3 => 6.0,
      4 => 8.0,
      5 => 12.0,
      _ => 6.0,
    };

    final double blurVal = offsetVal * 2.0;

    final Color lightColor = isDarkMode
        ? const Color(0x3D2C2722) // White glow equivalent in dark mode
        : const Color(0xFFFFFFFF); // Pure white light source

    final Color darkColor = isDarkMode
        ? const Color(0xB30C0A09) // Deep black shadow in dark mode
        : const Color(0x99D7D4CD); // Warm gray shadow in light mode

    final double shadowFactor = pressed ? -1.0 : 1.0;

    return [
      BoxShadow(
        color: lightColor,
        offset: Offset(-offsetVal * shadowFactor, -offsetVal * shadowFactor),
        blurRadius: blurVal,
        spreadRadius: 0.0,
      ),
      BoxShadow(
        color: darkColor,
        offset: Offset(offsetVal * shadowFactor, offsetVal * shadowFactor),
        blurRadius: blurVal,
        spreadRadius: 0.0,
      ),
    ];
  }
}
