import 'package:flutter/material.dart';
import '../API/number_fact.dart';
import '../presentation/widgets/widgets.dart';

class BalanceOverview extends StatefulWidget {
  final int number;

  const BalanceOverview({super.key, required this.number});

  @override
  State<BalanceOverview> createState() => _BalanceOverviewState();
}

class _BalanceOverviewState extends State<BalanceOverview> {
  String fact = 'Loading…';
  late String balanceO;

  @override
  void initState() {
    super.initState();
    balanceO = widget.number.toString();
    _loadFact();
  }

  Future<void> _loadFact() async {
    final value = await fetchNumberFact('trivia', widget.number.toString());
    if (mounted) {
      setState(() => fact = value);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  CurrencyFormatter.format(
                    double.tryParse(balanceO) ?? widget.number.toDouble(),
                  ),
                  style: CurrencyFormatter.amountStyle(
                    context.textTheme.displayMedium,
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
                      'Number Trivia',
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: StitchSpacing.md),
                Text(
                  fact,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: StitchFab(
        onPressed: _loadFact,
        icon: Icons.refresh_rounded,
        tooltip: 'Refresh trivia',
        heroTag: 'balance_overview_refresh',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
