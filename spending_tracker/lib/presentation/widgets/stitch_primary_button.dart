import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'stitch_loading_indicator.dart';

/// Primary filled action button from the Stitch design system.
class StitchPrimaryButton extends StatelessWidget {
  const StitchPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: StitchLoadingIndicator(strokeWidth: 2, compact: true),
          )
        : (icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: StitchSpacing.sm),
                    Text(label),
                  ],
                )
              : Text(label));

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: padding != null
          ? FilledButton.styleFrom(padding: padding)
          : null,
      child: child,
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
