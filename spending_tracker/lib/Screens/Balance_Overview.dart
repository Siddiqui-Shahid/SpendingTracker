import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';
import '../presentation/widgets/widgets.dart';

class BalanceOverview extends StatelessWidget {
  final int number;

  const BalanceOverview({super.key, required this.number});

  String _balanceInsight(double balance) {
    if (balance < 0) {
      return 'Your balance is negative. Review recent expenses and consider adjusting spending.';
    }
    if (balance < 1000) {
      return 'Keep logging small purchases — they add up quickly over the month.';
    }
    if (balance < 10000) {
      return 'You are building a healthy buffer. Set a monthly budget to stay on track.';
    }
    return 'Strong balance. Consider allocating a portion to savings or investments.';
  }

  @override
  Widget build(BuildContext context) {
    final balance = number.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Overview'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(StitchSpacing.md),
        children: [
          StitchAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Left',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: StitchSpacing.sm),
                Semantics(
                  label: 'Current balance',
                  value: CurrencyFormatter.format(balance),
                  child: Text(
                    CurrencyFormatter.format(balance),
                    style: CurrencyFormatter.amountStyle(
                      context.textTheme.displayMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: StitchSpacing.md),
          StitchAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: context.colors.tertiary,
                    ),
                    const SizedBox(width: StitchSpacing.sm),
                    Text(
                      'Insight',
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: StitchSpacing.md),
                Text(
                  _balanceInsight(balance),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
