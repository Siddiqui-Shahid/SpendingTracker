import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/Expense_data.dart';
import '../Model/Expense_item.dart';
import '../Data/hive_database.dart';
import '../core/utils/category_utils.dart';
import '../presentation/widgets/widgets.dart';

enum Period { week, month, year }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  Period selectedPeriod = Period.month;
  late DateTime startDate;
  late DateTime endDate;
  bool isCustomSelected = false;
  DateTime? customStartDate;
  DateTime? customEndDate;
  String? customLabel;

  @override
  void initState() {
    super.initState();
    _setDateRange(Period.month);
  }

  void _setDateRange(Period period) {
    final now = DateTime.now();
    setState(() {
      selectedPeriod = period;
      isCustomSelected = false;
      switch (period) {
        case Period.week:
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
        case Period.month:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
        case Period.year:
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
      }
    });
  }

  List<ExpenseItem> _getExpensesForPeriod(
    List<dynamic> allExpenses, {
    String? type,
  }) {
    return allExpenses.whereType<ExpenseItem>().where((expense) {
      final inRange = !expense.dateTime.isBefore(startDate) &&
          !expense.dateTime.isAfter(endDate.add(const Duration(days: 1)));
      if (type != null) return inRange && expense.type == type;
      return inRange;
    }).toList();
  }

  double _calculateTotal(List<ExpenseItem> expenses) {
    return expenses.fold<double>(
      0,
      (sum, expense) => sum + (double.tryParse(expense.amount) ?? 0),
    );
  }

  Map<String, double> _getSpendingByCategory(List<ExpenseItem> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      final category = CategoryUtils.extractCategory(expense.name);
      final amount = double.tryParse(expense.amount) ?? 0;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
    return categoryTotals;
  }

  Map<String, double> _dailyTotals(List<ExpenseItem> expenses) {
    final totals = <String, double>{};
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final expense in expenses) {
      final key = days[expense.dateTime.weekday - 1];
      final amount = double.tryParse(expense.amount) ?? 0;
      totals[key] = (totals[key] ?? 0) + amount;
    }
    return totals;
  }

  List<MapEntry<String, double>> _getTopCategories(
    Map<String, double> categoryTotals,
  ) {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  Future<void> _showCustomDateRangeDialog() async {
    DateTime? tempStart = customStartDate;
    DateTime? tempEnd = customEndDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      tempStart == null
                          ? 'Select Start Date'
                          : 'Start: ${tempStart!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempStart ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: tempEnd ?? DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempStart = picked;
                          if (tempEnd != null && tempEnd!.isBefore(tempStart!)) {
                            tempEnd = null;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      tempEnd == null
                          ? 'Select End Date'
                          : 'End: ${tempEnd!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempEnd ?? (tempStart ?? DateTime.now()),
                        firstDate: tempStart ?? DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => tempEnd = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                StitchSecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                StitchPrimaryButton(
                  label: 'Apply',
                  onPressed: (tempStart != null && tempEnd != null)
                      ? () {
                          setState(() {
                            isCustomSelected = true;
                            customStartDate = tempStart;
                            customEndDate = tempEnd;
                            startDate = customStartDate!;
                            endDate = customEndDate!;
                            customLabel =
                                '${customStartDate!.toLocal().toString().split(' ')[0]} - '
                                '${customEndDate!.toLocal().toString().split(' ')[0]}';
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _periodLabel() {
    if (isCustomSelected) return customLabel ?? 'Custom';
    return switch (selectedPeriod) {
      Period.week => 'This Week',
      Period.month => 'This Month',
      Period.year => 'This Year',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, expenseData, _) {
        final allExpenses = expenseData.getExpenseList();
        final periodExpenses =
            _getExpensesForPeriod(allExpenses, type: 'expense');
        final periodIncome = _getExpensesForPeriod(allExpenses, type: 'income');
        final totalSpending = _calculateTotal(periodExpenses);
        final totalEarning = _calculateTotal(periodIncome);
        final categoryTotals = _getSpendingByCategory(periodExpenses);
        final topCategories = _getTopCategories(categoryTotals);
        final dailyTotals = _dailyTotals(periodExpenses);

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.spendingInsights),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StitchStatisticsCard(
                  periodLabel: _periodLabel(),
                  spentAmount: totalSpending,
                  earnedAmount: totalEarning,
                  netAmount: totalEarning - totalSpending,
                ),
                StitchPeriodFilterChips(
                  labels: const ['Week', 'Month', 'Year'],
                  selectedIndex: selectedPeriod.index,
                  isCustomSelected: isCustomSelected,
                  customLabel: customLabel,
                  onSelected: (index) => _setDateRange(Period.values[index]),
                  onCustomTap: _showCustomDateRangeDialog,
                ),
                Padding(
                  padding: const EdgeInsets.all(StitchSpacing.md),
                  child: StitchAppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending by Category',
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: StitchSpacing.md),
                        Center(
                          child: StitchDonutChart(
                            categoryTotals: categoryTotals,
                            totalSpending: totalSpending,
                          ),
                        ),
                        if (categoryTotals.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: StitchSpacing.sm),
                          ..._buildCategoryLegend(categoryTotals, totalSpending),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StitchSpacing.md,
                  ),
                  child: StitchAppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Trend',
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: StitchSpacing.md),
                        StitchDailyBarChart(dailyTotals: dailyTotals),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(StitchSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StitchSectionHeader(
                        title: 'Top Spending Categories',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: StitchSpacing.sm),
                      ..._buildTopCategoriesList(topCategories, totalSpending),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCategoryLegend(
    Map<String, double> categoryTotals,
    double totalSpending,
  ) {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final storedCategories = HiveDataBase().getCategory();

    return [
      for (var i = 0; i < sorted.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
          child: Row(
            children: [
              Text(
                CategoryUtils.emojiForCategoryName(
                      sorted[i].key,
                      storedCategories,
                    ) ??
                    '•',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: StitchSpacing.sm),
              Expanded(child: Text(sorted[i].key)),
              Text(
                totalSpending > 0
                    ? '${((sorted[i].value / totalSpending) * 100).toStringAsFixed(1)}%'
                    : '0%',
                style: context.textTheme.labelLarge,
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _buildTopCategoriesList(
    List<MapEntry<String, double>> topCategories,
    double totalSpending,
  ) {
    final storedCategories = HiveDataBase().getCategory();

    return topCategories.map((entry) {
      final percentage =
          totalSpending > 0 ? (entry.value / totalSpending) * 100 : 0.0;
      final emoji = CategoryUtils.emojiForCategoryName(
        entry.key,
        storedCategories,
      );
      return StitchCategoryCard.insight(
        label: entry.key,
        emoji: emoji,
        percentage: percentage,
        amount: entry.value.toStringAsFixed(2),
      );
    }).toList();
  }
}
