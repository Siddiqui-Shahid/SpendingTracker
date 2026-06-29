import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'stitch_app_card.dart';

/// Income / expense / net summary for a selected period.
class StitchStatisticsCard extends StatelessWidget {
  const StitchStatisticsCard({
    super.key,
    required this.periodLabel,
    required this.spentAmount,
    required this.earnedAmount,
    required this.netAmount,
    this.currencySymbol = '₹',
  });

  final String periodLabel;
  final double spentAmount;
  final double earnedAmount;
  final double netAmount;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.stitchSemantics;
    final textTheme = context.textTheme;
    final netPositive = netAmount >= 0;
    final netColor = netPositive ? colors.primary : colors.error;
    final netPrefix = netPositive ? '+' : '';

    return Padding(
      padding: EdgeInsets.all(context.stitchSpacing.gutter),
      child: StitchAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              periodLabel,
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: StitchSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MetricColumn(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Spent',
                  value:
                      '-$currencySymbol${spentAmount.toStringAsFixed(2)}',
                  color: semantics.expense,
                  iconBackground: semantics.expense.withValues(alpha: 0.12),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                _MetricColumn(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Earned',
                  value:
                      '+$currencySymbol${earnedAmount.toStringAsFixed(2)}',
                  color: semantics.income,
                  iconBackground: semantics.income.withValues(alpha: 0.12),
                ),
              ],
            ),
            const SizedBox(height: StitchSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: netColor.withValues(alpha: 0.1),
                borderRadius: context.stitchShapes.borderRadiusMd,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: StitchSpacing.md,
                vertical: StitchSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    netPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: netColor,
                    size: 22,
                  ),
                  const SizedBox(width: StitchSpacing.sm),
                  Text(
                    'Net: $netPrefix$currencySymbol${netAmount.abs().toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: netColor,
                      fontFeatures: StitchTypography.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconBackground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: context.stitchShapes.borderRadiusMd,
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: StitchSpacing.xs),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: color,
            fontFeatures: StitchTypography.tabularFigures,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
