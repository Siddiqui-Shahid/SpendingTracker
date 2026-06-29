import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'stitch_primary_button.dart';

/// Error placeholder with optional retry action.
class StitchErrorState extends StatelessWidget {
  const StitchErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Try Again',
    this.onRetry,
  });

  final String message;
  final String title;
  final IconData icon;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StitchSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.error),
            const SizedBox(height: StitchSpacing.md),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: StitchSpacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: StitchSpacing.lg),
              StitchPrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
