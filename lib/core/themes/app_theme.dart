import 'package:flutter/material.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'RedHatDisplay',
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySmall,
      labelSmall: AppTextStyles.caption,
    ),
  );
}
