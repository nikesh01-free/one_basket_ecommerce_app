import 'package:flutter/material.dart';

abstract class OBTypography {
  static const String headingFont = 'Poppins';
  static const String bodyFont = 'Inter';

  static const TextStyle displayXL = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w700,
    fontSize: 40.0,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayL = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w700,
    fontSize: 32.0,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 28.0,
    height: 1.3,
    letterSpacing: 0.0,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    height: 1.3,
    letterSpacing: 0.0,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle title = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w700,
    fontSize: 10.0,
    height: 1.4,
    letterSpacing: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: headingFont,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    height: 1.0,
    letterSpacing: 0.5,
  );
}
