import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Themed loading indicator for inline and full-screen use.
class StitchLoadingIndicator extends StatelessWidget {
  const StitchLoadingIndicator({
    super.key,
    this.message,
    this.strokeWidth = 3,
    this.compact = false,
  });

  final String? message;
  final double strokeWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: compact ? 20 : 36,
      height: compact ? 20 : 36,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: context.colors.primary,
      ),
    );

    if (message == null) return indicator;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: StitchSpacing.md),
        Text(
          message!,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
