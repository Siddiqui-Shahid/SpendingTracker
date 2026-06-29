import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';

/// Large currency display for the add-transaction screen.
class StitchAmountDisplay extends StatelessWidget {
  const StitchAmountDisplay({
    super.key,
    required this.amountText,
    this.currencySymbol = AppStrings.currencySymbol,
    this.label,
    this.isExpense = true,
  });

  final String amountText;
  final String currencySymbol;
  final String? label;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.stitchSemantics;
    final textTheme = context.textTheme;
    final display = amountText.isEmpty ? '0' : amountText;
    final accent = isExpense ? semantics.expense : semantics.income;

    return Semantics(
      label: 'Amount $currencySymbol$display',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.stitchSpacing.gutter,
          vertical: context.stitchSpacing.md,
        ),
        child: Column(
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: StitchSpacing.sm),
            ],
            Text(
              '$currencySymbol$display',
              style: textTheme.displayLarge?.copyWith(
                color: accent,
                fontFeatures: StitchTypography.tabularFigures,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
