import 'package:flutter/material.dart';

abstract class OBSpacing {
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space14 = 56.0;
  static const double space16 = 64.0;

  // Layout Padding Helpers
  static const EdgeInsets pagePadding = EdgeInsets.all(space4);
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(horizontal: space4);
  static const EdgeInsets cardPadding = EdgeInsets.all(space4);
}
