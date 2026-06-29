import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/stitch_typography.dart';

/// Tabular-figure currency formatting aligned with Stitch typography.
abstract final class CurrencyFormatter {
  static String format(
    num amount, {
    String symbol = AppStrings.currencySymbol,
    int fractionDigits = 2,
    bool showSymbol = true,
  }) {
    final value = amount.toStringAsFixed(fractionDigits);
    if (!showSymbol) return value;
    return '$symbol$value';
  }

  static String formatCompact(
    num amount, {
    String symbol = AppStrings.currencySymbol,
  }) {
    final abs = amount.abs();
    if (abs >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (abs >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, fractionDigits: abs == abs.roundToDouble() ? 0 : 2);
  }

  static TextStyle? amountStyle(TextStyle? base, {Color? color}) {
    return base?.copyWith(
      color: color,
      fontFeatures: StitchTypography.tabularFigures,
      fontWeight: FontWeight.w700,
    );
  }
}
