import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Date group header ("Today", "Yesterday", formatted date).
class StitchDateSectionHeader extends StatelessWidget {
  const StitchDateSectionHeader({
    super.key,
    required this.label,
    this.padding,
  });

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            context.stitchSpacing.gutter,
            context.stitchSpacing.md,
            context.stitchSpacing.gutter,
            context.stitchSpacing.xs,
          ),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
