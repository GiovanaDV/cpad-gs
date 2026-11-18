import 'package:flutter/material.dart';

class AppColors {
  static const purple = Color(0xFF4527A0);
  static const navy = Color(0xFF1E1B5E);
  static const blue = Color(0xFF1E6FD0);
  static const amber = Color(0xFFF9A825);
  static const teal = Color(0xFF1B7F68);

  static const primary = purple;
  static const secondary = blue;
  static const riskLow = teal;
  static const riskMedium = Color(0xFFB26A00);
  static const riskHigh = Color(0xFFC62828);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

class AppText {
  static const family = 'Inter';

  static const textTheme = TextTheme(
    headlineLarge: TextStyle(fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700), // H1
    headlineMedium: TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700), // H2
    headlineSmall: TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontFamily: family, fontSize: 20, fontWeight: FontWeight.w600), // H3
    titleMedium: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600), // H4
    titleSmall: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400), // Body
    bodySmall: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400), // Body Small
    labelLarge: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600), // Botões
    labelMedium: TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w500), // Labels
    labelSmall: TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w500), // Caption
  );
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: brightness);

    final scheme = dark
        ? base.copyWith(
            primary: const Color(0xFFB7A6FF),
            onPrimary: AppColors.navy,
            secondary: const Color(0xFF7DB8FF),
            onSecondary: AppColors.navy,
            surface: const Color(0xFF1E1C45),
            onSurface: const Color(0xFFEDEBFF),
            tertiaryContainer: const Color(0xFF4A3600),
            onTertiaryContainer: const Color(0xFFFFE2A0),
          )
        : base.copyWith(
            primary: AppColors.purple,
            onPrimary: Colors.white,
            secondary: AppColors.blue,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.navy,
            tertiaryContainer: const Color(0xFFFFF0CC),
            onTertiaryContainer: const Color(0xFF5A3A00),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppText.family,
      textTheme: AppText.textTheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF121127) : const Color(0xFFF6F5FC),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF2A2468) : AppColors.purple,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: AppText.family,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}