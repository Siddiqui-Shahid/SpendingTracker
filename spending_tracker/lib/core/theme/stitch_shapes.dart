import 'package:flutter/material.dart';

/// Stitch corner-radius tokens (`ROUND_EIGHT` base).
abstract final class StitchShapes {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius radiusTopSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  static const BorderRadius radiusTopDialog = BorderRadius.all(
    Radius.circular(xxl),
  );

  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(999));
}

/// Access shape tokens from [ThemeData.extensions].
@immutable
class StitchShapesTheme extends ThemeExtension<StitchShapesTheme> {
  const StitchShapesTheme({
    this.sm = StitchShapes.sm,
    this.md = StitchShapes.md,
    this.lg = StitchShapes.lg,
    this.xl = StitchShapes.xl,
    this.xxl = StitchShapes.xxl,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  static const StitchShapesTheme standard = StitchShapesTheme();

  BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  BorderRadius get borderRadiusXxl => BorderRadius.circular(xxl);
  BorderRadius get borderRadiusPill => BorderRadius.circular(999);

  @override
  StitchShapesTheme copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return StitchShapesTheme(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  StitchShapesTheme lerp(ThemeExtension<StitchShapesTheme>? other, double t) {
    if (other is! StitchShapesTheme) return this;
    return this;
  }
}
