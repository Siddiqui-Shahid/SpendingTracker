import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Section title row with optional trailing action.
class StitchSectionHeader extends StatelessWidget {
  const StitchSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
    this.compact = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final style = compact
        ? textTheme.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            letterSpacing: 0.5,
          )
        : textTheme.headlineMedium;

    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: context.stitchSpacing.gutter,
            vertical: context.stitchSpacing.sm,
          ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
