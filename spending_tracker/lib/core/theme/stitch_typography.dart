import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_spendz/utils.dart';

/// Stitch / ZenSpend typography using Inter across all M3 roles.
abstract final class StitchTypography {
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(ColorScheme colors) {
    final base = _interTextTheme(colors);
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
        fontFeatures: tabularFigures,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.28,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.35,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.35,
      ),
    );
  }

  /// Currency and balance display styles.
  static TextStyle balanceDisplay(ColorScheme colors, TextTheme textTheme) {
    return (textTheme.displayLarge ?? const TextStyle()).copyWith(
      color: colors.onSurface,
      fontFeatures: tabularFigures,
    );
  }

  static TextStyle currencyAmount(
    ColorScheme colors,
    TextTheme textTheme, {
    bool isIncome = false,
    bool isExpense = false,
  }) {
    Color color = colors.onSurface;
    if (isIncome) color = colors.tertiary;
    if (isExpense) color = colors.error;

    return (textTheme.titleMedium ?? const TextStyle()).copyWith(
      color: color,
      fontFeatures: tabularFigures,
      fontWeight: FontWeight.w600,
    );
  }

  static TextTheme _interTextTheme(ColorScheme colors) {
    try {
      return GoogleFonts.interTextTheme(
        ThemeData(brightness: colors.brightness).textTheme,
      ).apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      );
    } catch (_) {
      final fallback = SafeGoogleFont(
        'Source Sans Pro',
        color: colors.onSurface,
      );
      return TextTheme(
        displayLarge: fallback.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
        displayMedium: fallback.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        displaySmall: fallback.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        headlineLarge: fallback.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: fallback.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: fallback.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: fallback.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: fallback.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: fallback.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: fallback.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: fallback.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: fallback.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: fallback.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: fallback.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: fallback.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
      );
    }
  }
}
