import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'radius.dart';

InputDecorationTheme getTextFieldTheme(bool isDark) {
  return InputDecorationTheme(
    filled: true,
    fillColor: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? const Color(0xFF453E36) : OBColors.neutral300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? const Color(0xFF453E36) : OBColors.neutral300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? OBColors.primary400 : OBColors.primary500, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? OBColors.errorDark : OBColors.error, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: isDark ? OBColors.errorDark : OBColors.error, width: 2.0),
    ),
    labelStyle: TextStyle(color: isDark ? OBColors.neutral300 : OBColors.neutral700),
    hintStyle: const TextStyle(color: OBColors.neutral400),
  );
}

class OBTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: OBColors.primary500,
      scaffoldBackgroundColor: OBColors.neutral50,
      
      colorScheme: const ColorScheme.light(
        primary: OBColors.primary500,
        secondary: OBColors.primary200,
        surface: OBColors.neutral50,
        error: OBColors.error,
        onPrimary: Colors.white,
        onSecondary: OBColors.neutral800,
        onSurface: OBColors.neutral900,
        onError: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: OBTypography.displayXL.copyWith(color: OBColors.neutral900),
        displayMedium: OBTypography.displayL.copyWith(color: OBColors.neutral900),
        headlineLarge: OBTypography.heading1.copyWith(color: OBColors.neutral900),
        headlineMedium: OBTypography.heading2.copyWith(color: OBColors.neutral800),
        headlineSmall: OBTypography.heading3.copyWith(color: OBColors.neutral800),
        titleLarge: OBTypography.title.copyWith(color: OBColors.neutral900),
        titleMedium: OBTypography.subtitle.copyWith(color: OBColors.neutral800),
        bodyLarge: OBTypography.bodyLarge.copyWith(color: OBColors.neutral800),
        bodyMedium: OBTypography.body.copyWith(color: OBColors.neutral700),
        bodySmall: OBTypography.caption.copyWith(color: OBColors.neutral500),
      ),

      inputDecorationTheme: getTextFieldTheme(false),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: OBColors.neutral800),
        titleTextStyle: TextStyle(
          fontFamily: OBTypography.headingFont,
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
          color: OBColors.neutral800,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: OBColors.neutral50,
        shape: const RoundedRectangleBorder(borderRadius: OBRadius.lg),
        titleTextStyle: OBTypography.heading2.copyWith(color: OBColors.neutral900),
        contentTextStyle: OBTypography.body.copyWith(color: OBColors.neutral700),
      ),

      cardTheme: const CardThemeData(
        color: OBColors.neutral100,
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: OBRadius.md),
      ),

      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary500;
          return Colors.transparent;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary500;
          return OBColors.neutral400;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return OBColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary500;
          return OBColors.neutral200;
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        backgroundColor: OBColors.neutral800,
        contentTextStyle: OBTypography.body.copyWith(color: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: OBColors.primary400,
      scaffoldBackgroundColor: OBColors.neutral900,

      colorScheme: const ColorScheme.dark(
        primary: OBColors.primary400,
        secondary: OBColors.primary700,
        surface: OBColors.neutral900,
        error: OBColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.black,
      ),

      textTheme: TextTheme(
        displayLarge: OBTypography.displayXL.copyWith(color: Colors.white),
        displayMedium: OBTypography.displayL.copyWith(color: Colors.white),
        headlineLarge: OBTypography.heading1.copyWith(color: Colors.white),
        headlineMedium: OBTypography.heading2.copyWith(color: Colors.white),
        headlineSmall: OBTypography.heading3.copyWith(color: OBColors.neutral200),
        titleLarge: OBTypography.title.copyWith(color: Colors.white),
        titleMedium: OBTypography.subtitle.copyWith(color: Colors.white),
        bodyLarge: OBTypography.bodyLarge.copyWith(color: OBColors.neutral200),
        bodyMedium: OBTypography.body.copyWith(color: OBColors.neutral300),
        bodySmall: OBTypography.caption.copyWith(color: OBColors.neutral400),
      ),

      inputDecorationTheme: getTextFieldTheme(true),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: OBTypography.headingFont,
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1C1917),
        shape: const RoundedRectangleBorder(borderRadius: OBRadius.lg),
        titleTextStyle: OBTypography.heading2.copyWith(color: Colors.white),
        contentTextStyle: OBTypography.body.copyWith(color: OBColors.neutral300),
      ),

      cardTheme: const CardThemeData(
        color: Color(0xFF2C2722),
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: OBRadius.md),
      ),

      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.black),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary400;
          return Colors.transparent;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary400;
          return OBColors.neutral500;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.neutral800;
          return OBColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OBColors.primary400;
          return const Color(0xFF2C2722);
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        backgroundColor: OBColors.neutral200,
        contentTextStyle: OBTypography.body.copyWith(color: OBColors.neutral900),
      ),
    );
  }
}
