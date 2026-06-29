import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Two-column income / expense summary for the dashboard.
class StitchIncomeExpenseSummary extends StatelessWidget {
  const StitchIncomeExpenseSummary({
    super.key,
    required this.incomeAmount,
    required this.expenseAmount,
    this.currencySymbol = AppStrings.currencySymbol,
  });

  final double incomeAmount;
  final double expenseAmount;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final semantics = context.stitchSemantics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.stitchSpacing.gutter),
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              label: 'Income',
              amount: incomeAmount,
              icon: Icons.arrow_upward_rounded,
              iconColor: semantics.income,
              containerColor: semantics.incomeContainer.withValues(alpha: 0.35),
              currencySymbol: currencySymbol,
            ),
          ),
          SizedBox(width: context.stitchSpacing.md),
          Expanded(
            child: _SummaryColumn(
              label: 'Expenses',
              amount: expenseAmount,
              icon: Icons.arrow_downward_rounded,
              iconColor: semantics.expense,
              containerColor: semantics.expenseContainer.withValues(alpha: 0.35),
              currencySymbol: currencySymbol,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.containerColor,
    required this.currencySymbol,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color containerColor;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Semantics(
      label: '$label ${CurrencyFormatter.format(amount, symbol: currencySymbol)}',
      child: Container(
        padding: const EdgeInsets.all(StitchSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: context.stitchShapes.borderRadiusXl,
          border: Border.all(color: context.stitchSemantics.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: context.stitchShapes.borderRadiusMd,
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: StitchSpacing.sm),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StitchSpacing.sm),
            Text(
              CurrencyFormatter.format(amount, symbol: currencySymbol),
              style: CurrencyFormatter.amountStyle(
                textTheme.titleLarge,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
