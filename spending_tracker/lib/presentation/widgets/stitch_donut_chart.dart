import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Donut chart for category spending (Stitch Spending Insights).
class StitchDonutChart extends StatelessWidget {
  const StitchDonutChart({
    super.key,
    required this.categoryTotals,
    required this.totalSpending,
    this.colors,
    this.size = 160,
    this.currencySymbol = AppStrings.currencySymbol,
  });

  final Map<String, double> categoryTotals;
  final double totalSpending;
  final List<Color>? colors;
  final double size;
  final String currencySymbol;

  List<Color> _palette(BuildContext context) {
    if (colors != null && colors!.isNotEmpty) return colors!;
    final scheme = context.colors;
    return [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.error,
      scheme.primaryContainer,
      scheme.tertiaryContainer,
      scheme.secondaryContainer,
      scheme.outline,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty || totalSpending <= 0) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'No spending data',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final palette = _palette(context);
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Semantics(
      label: 'Spending by category chart',
      child: SizedBox(
        height: size + 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.35,
                  startDegreeOffset: -90,
                  sections: [
                    for (var i = 0; i < sorted.length; i++)
                      PieChartSectionData(
                        value: sorted[i].value,
                        color: palette[i % palette.length],
                        radius: size * 0.22,
                        showTitle: false,
                        borderSide: BorderSide.none,
                      ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    totalSpending,
                    symbol: currencySymbol,
                    fractionDigits: 0,
                  ),
                  style: CurrencyFormatter.amountStyle(
                    context.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
