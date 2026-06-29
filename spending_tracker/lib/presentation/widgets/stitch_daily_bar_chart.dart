import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Daily spending bar chart for insights.
class StitchDailyBarChart extends StatelessWidget {
  const StitchDailyBarChart({
    super.key,
    required this.dailyTotals,
    this.height = 180,
    this.currencySymbol = AppStrings.currencySymbol,
  });

  /// Map of day label → amount (e.g. "Mon" → 120.0).
  final Map<String, double> dailyTotals;
  final double height;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (dailyTotals.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No daily trend data',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final colors = context.colors;
    final entries = dailyTotals.entries.toList();
    final maxY = entries.fold<double>(
      0,
      (max, e) => e.value > max ? e.value : max,
    );

    return Semantics(
      label: 'Daily spending trend chart',
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            maxY: maxY <= 0 ? 1 : maxY * 1.15,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (_) => FlLine(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: StitchSpacing.xs),
                      child: Text(
                        entries[index].key,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < entries.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value,
                      color: colors.primaryContainer,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(StitchShapes.sm),
                      ),
                    ),
                  ],
                ),
            ],
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    CurrencyFormatter.format(
                      rod.toY,
                      symbol: currencySymbol,
                      fractionDigits: 0,
                    ),
                    context.textTheme.labelMedium!.copyWith(
                      color: colors.onInverseSurface,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
