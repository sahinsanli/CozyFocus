import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: brightness,
      primary: dark ? const Color(0xFFB8CDAA) : AppColors.sage,
      secondary: dark ? const Color(0xFFFFB4AB) : AppColors.terracotta,
      surface: dark ? AppColors.darkSurface : AppColors.cream,
    );
    final base = dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final body = base.apply(
      fontFamily: 'Nunito Sans',
      bodyColor: dark ? const Color(0xFFF8EEE9) : AppColors.ink,
      displayColor: dark ? const Color(0xFFF8EEE9) : AppColors.ink,
    );
    final titles = base.apply(
      fontFamily: 'Quicksand',
      bodyColor: dark ? const Color(0xFFF8EEE9) : AppColors.ink,
      displayColor: dark ? const Color(0xFFF8EEE9) : AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? AppColors.darkBackground
          : AppColors.cream,
      textTheme: titles.copyWith(
        bodyLarge: body.bodyLarge?.copyWith(fontSize: 17, height: 1.45),
        bodyMedium: body.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
        bodySmall: body.bodySmall?.copyWith(fontSize: 13, height: 1.35),
        labelLarge: body.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: .3,
        ),
        titleLarge: titles.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        headlineMedium: titles.headlineMedium?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.18,
        ),
        displaySmall: titles.displaySmall?.copyWith(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: dark ? const Color(0xFFB8CDAA) : AppColors.sage,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? AppColors.darkCard : Colors.white.withValues(alpha: .82),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: scheme.outlineVariant.withValues(alpha: .35),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant.withValues(alpha: .45),
        thumbColor: scheme.primary,
        trackHeight: 4,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outlineVariant,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
