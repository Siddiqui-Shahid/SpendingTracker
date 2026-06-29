import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'stitch_primary_button.dart';
import 'stitch_secondary_button.dart';

/// Styled confirmation / success dialog aligned with Stitch M3 theme.
class StitchConfirmationDialog extends StatelessWidget {
  const StitchConfirmationDialog({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.primaryLabel = 'OK',
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.destructive = false,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final bool destructive;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    IconData? icon,
    Color? iconColor,
    String primaryLabel = 'OK',
    String? secondaryLabel,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool destructive = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => StitchConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (iconColor ?? colors.primaryContainer).withValues(
                  alpha: destructive ? 0.2 : 0.35,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ??
                    (destructive ? colors.error : colors.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: StitchSpacing.md),
          ],
          if (message != null)
            Text(
              message!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        if (secondaryLabel != null)
          StitchSecondaryButton(
            label: secondaryLabel!,
            onPressed: () {
              Navigator.of(context).pop();
              onSecondary?.call();
            },
          ),
        StitchPrimaryButton(
          label: primaryLabel,
          onPressed: () {
            Navigator.of(context).pop();
            onPrimary?.call();
          },
        ),
      ],
    );
  }
}
