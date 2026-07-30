import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// One bar in the spending trend chart.
class SpendingTrendPoint {
  const SpendingTrendPoint({
    required this.label,
    required this.amount,
    required this.tooltipLabel,
  });

  /// Short axis label (e.g. "Mon 21", "12", "Jan").
  final String label;

  final double amount;

  /// Full label for tooltips (e.g. "Monday, Jul 21").
  final String tooltipLabel;
}

/// Spending trend bar chart for insights (daily / monthly buckets).
class StitchDailyBarChart extends StatelessWidget {
  const StitchDailyBarChart({
    super.key,
    required this.points,
    this.height = 200,
    this.currencySymbol = AppStrings.currencySymbol,
  });

  final List<SpendingTrendPoint> points;
  final double height;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No spending in this period',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final colors = context.colors;
    final maxY = points.fold<double>(
      0,
      (max, e) => e.amount > max ? e.amount : max,
    );
    final barWidth = points.length > 20
        ? 5.0
        : points.length > 12
            ? 8.0
            : points.length > 7
                ? 12.0
                : 16.0;
    final labelStep = points.length > 16
        ? 5
        : points.length > 10
            ? 2
            : 1;

    return Semantics(
      label: 'Spending trend chart',
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            maxY: maxY <= 0 ? 1 : maxY * 1.2,
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
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxY > 0 ? maxY / 2 : 1,
                  getTitlesWidget: (value, meta) {
                    if (value <= 0 || value > maxY * 1.05) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      CurrencyFormatter.format(
                        value,
                        symbol: currencySymbol,
                        fractionDigits: 0,
                      ),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    // Always show first/last; thin middle labels when crowded.
                    final show = index == 0 ||
                        index == points.length - 1 ||
                        index % labelStep == 0;
                    if (!show) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: StitchSpacing.xs),
                      child: Text(
                        points[index].label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < points.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: points[i].amount <= 0 ? 0 : points[i].amount,
                      color: points[i].amount > 0
                          ? colors.primaryContainer
                          : colors.outlineVariant.withValues(alpha: 0.35),
                      width: barWidth,
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
                  final point = points[group.x.toInt()];
                  return BarTooltipItem(
                    '${point.tooltipLabel}\n'
                    '${CurrencyFormatter.format(
                      point.amount,
                      symbol: currencySymbol,
                      fractionDigits: 0,
                    )}',
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
