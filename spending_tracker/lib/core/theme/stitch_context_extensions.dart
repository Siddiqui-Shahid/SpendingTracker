import 'package:flutter/material.dart';
import 'stitch_semantic_colors.dart';
import 'stitch_shapes.dart';
import 'stitch_spacing.dart';

/// Convenient access to Stitch theme extensions from [BuildContext].
extension StitchThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  StitchSpacingTheme get stitchSpacing =>
      theme.extension<StitchSpacingTheme>() ?? StitchSpacingTheme.standard;

  StitchShapesTheme get stitchShapes =>
      theme.extension<StitchShapesTheme>() ?? StitchShapesTheme.standard;

  StitchSemanticColors get stitchSemantics =>
      theme.extension<StitchSemanticColors>() ??
      StitchSemanticColors.from(colors);
}
