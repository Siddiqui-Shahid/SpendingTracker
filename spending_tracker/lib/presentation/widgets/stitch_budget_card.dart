import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Hero balance card shown on the dashboard.
class StitchBudgetCard extends StatelessWidget {
  const StitchBudgetCard({
    super.key,
    required this.label,
    required this.amount,
    this.onTap,
    this.currencySymbol = AppStrings.currencySymbol,
    this.trailing,
    this.trendPercent,
    this.showDefaultTrailing = true,
  });

  final String label;
  final String amount;
  final VoidCallback? onTap;
  final String currencySymbol;
  final Widget? trailing;
  /// Optional trend badge, e.g. 2.4 for "+2.4%".
  final double? trendPercent;
  final bool showDefaultTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.stitchSpacing.gutter,
        StitchSpacing.sm,
        context.stitchSpacing.gutter,
        context.stitchSpacing.md,
      ),
      child: Material(
        color: colors.primaryContainer,
        borderRadius: context.stitchShapes.borderRadiusXxl,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(StitchSpacing.md),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onPrimaryContainer.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                          if (trendPercent != null) ...[
                            const SizedBox(width: StitchSpacing.sm),
                            _TrendBadge(percent: trendPercent!),
                          ],
                        ],
                      ),
                      const SizedBox(height: StitchSpacing.xs),
                      Text(
                        CurrencyFormatter.format(
                          double.tryParse(amount) ?? 0,
                          symbol: currencySymbol,
                        ),
                        style: CurrencyFormatter.amountStyle(
                          textTheme.displayLarge,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  if (trailing != null)
                    trailing!
                  else if (showDefaultTrailing)
                    Icon(
                      Icons.navigate_next_rounded,
                      size: 32,
                      color: colors.onPrimaryContainer,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final positive = percent >= 0;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.sm,
        vertical: StitchSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: context.stitchShapes.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: colors.onPrimaryContainer,
          ),
          const SizedBox(width: 2),
          Text(
            '${positive ? '+' : ''}${percent.toStringAsFixed(1)}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
