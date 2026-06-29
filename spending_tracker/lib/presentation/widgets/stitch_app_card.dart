import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Tonal surface card with optional tap handling.
class StitchAppCard extends StatelessWidget {
  const StitchAppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final shapes = context.stitchShapes;
    final radius = borderRadius ?? shapes.borderRadiusXxl;
    final cardColor =
        color ?? context.colors.surfaceContainerLow;

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: Border.all(color: context.stitchSemantics.cardBorder),
      ),
      child: Padding(
        padding: padding ?? StitchSpacing.cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}
