import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';

/// Numeric keypad (0–9, decimal, backspace) for amount entry.
class StitchNumericKeypad extends StatelessWidget {
  const StitchNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onDecimal,
    this.allowDecimal = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onDecimal;
  final bool allowDecimal;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.stitchSpacing.gutter),
      child: Column(
        children: [
          for (final row in _keys)
            Padding(
              padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StitchSpacing.xs,
                        ),
                        child: _KeyButton(
                          label: key,
                          onPressed: () => _handleKey(context, key),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleKey(BuildContext context, String key) {
    HapticFeedback.lightImpact();
    if (key == '⌫') {
      onBackspace();
      return;
    }
    if (key == '.') {
      if (allowDecimal) {
        (onDecimal ?? () => onDigit('.'))();
      }
      return;
    }
    onDigit(key);
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBackspace = label == '⌫';

    return Semantics(
      button: true,
      label: isBackspace ? 'Backspace' : 'Digit $label',
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: context.stitchShapes.borderRadiusMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: context.stitchShapes.borderRadiusMd,
          child: SizedBox(
            height: 52,
            child: Center(
              child: isBackspace
                  ? Icon(Icons.backspace_outlined, color: colors.onSurface)
                  : Text(
                      label,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: StitchTypography.tabularFigures,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
