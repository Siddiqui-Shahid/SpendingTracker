import 'package:flutter/material.dart';

/// Stitch 8px spacing grid.
abstract final class StitchSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal screen gutter on mobile.
  static const double gutter = md;

  /// Default outer margin for screen content.
  static const double marginMobile = md;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: marginMobile,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const double transactionListItemHeight = 72;
  static const double navigationBarHeight = 80;
  static const double fabSize = 56;
}

/// Access spacing tokens from [ThemeData.extensions].
@immutable
class StitchSpacingTheme extends ThemeExtension<StitchSpacingTheme> {
  const StitchSpacingTheme({
    this.xs = StitchSpacing.xs,
    this.sm = StitchSpacing.sm,
    this.md = StitchSpacing.md,
    this.lg = StitchSpacing.lg,
    this.xl = StitchSpacing.xl,
    this.xxl = StitchSpacing.xxl,
    this.gutter = StitchSpacing.gutter,
    this.marginMobile = StitchSpacing.marginMobile,
    this.transactionListItemHeight = StitchSpacing.transactionListItemHeight,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double gutter;
  final double marginMobile;
  final double transactionListItemHeight;

  static const StitchSpacingTheme standard = StitchSpacingTheme();

  @override
  StitchSpacingTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? gutter,
    double? marginMobile,
    double? transactionListItemHeight,
  }) {
    return StitchSpacingTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      gutter: gutter ?? this.gutter,
      marginMobile: marginMobile ?? this.marginMobile,
      transactionListItemHeight:
          transactionListItemHeight ?? this.transactionListItemHeight,
    );
  }

  @override
  StitchSpacingTheme lerp(ThemeExtension<StitchSpacingTheme>? other, double t) {
    if (other is! StitchSpacingTheme) return this;
    return this;
  }
}
