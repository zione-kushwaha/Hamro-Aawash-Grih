import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.w400, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, letterSpacing: 1.5),
      );
}
