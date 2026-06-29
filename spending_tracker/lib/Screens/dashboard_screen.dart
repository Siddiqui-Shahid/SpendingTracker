import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../Data/Expense_data.dart';
import '../Model/Expense_item.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/category_utils.dart';
import '../presentation/widgets/widgets.dart';
import 'addTransactionPage.dart';

/// Dashboard tab — hero balance, income/expense summary, recent activity.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onViewAll,
    this.onBalanceLongPress,
    this.onAddTransaction,
  });

  final VoidCallback? onViewAll;
  final VoidCallback? onBalanceLongPress;
  final VoidCallback? onAddTransaction;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseData>(context, listen: false).prepareData();
    });
  }

  ({double income, double expense}) _monthTotals(List<dynamic> expenses) {
    final now = DateTime.now();
    double income = 0;
    double expense = 0;

    for (final item in expenses.whereType<ExpenseItem>()) {
      if (item.dateTime.year != now.year || item.dateTime.month != now.month) {
        continue;
      }
      final amount = double.tryParse(item.amount) ?? 0;
      if (item.type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }

    return (income: income, expense: expense);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('DashboardScreenVisibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && mounted) {
          Provider.of<ExpenseData>(context, listen: false).prepareData();
        }
      },
      child: Consumer<ExpenseData>(
        builder: (context, value, _) {
          final balance = value.getBalance();
          final sorted = List<ExpenseItem>.from(
            value.getExpenseList().whereType<ExpenseItem>(),
          )..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          final totals = _monthTotals(sorted);
          final recent = sorted.take(5).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text(AppStrings.appName),
              centerTitle: true,
            ),
            body: ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + StitchSpacing.lg,
              ),
              children: [
                GestureDetector(
                  onLongPress: widget.onBalanceLongPress,
                  child: StitchBudgetCard(
                    label: AppStrings.dashboardBalanceLabel,
                    amount: balance.toString(),
                    showDefaultTrailing: false,
                  ),
                ),
                const SizedBox(height: StitchSpacing.sm),
                StitchIncomeExpenseSummary(
                  incomeAmount: totals.income,
                  expenseAmount: totals.expense,
                ),
                const SizedBox(height: StitchSpacing.md),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.stitchSpacing.gutter,
                  ),
                  child: StitchPrimaryButton(
                    label: AppStrings.addTransaction,
                    icon: Icons.add_rounded,
                    expand: true,
                    onPressed: widget.onAddTransaction,
                  ),
                ),
                const SizedBox(height: StitchSpacing.md),
                StitchSectionHeader(
                  title: AppStrings.recentActivity,
                  actionLabel: AppStrings.viewAll,
                  onAction: widget.onViewAll,
                ),
                if (recent.isEmpty)
                  StitchEmptyState(
                    message: widget.onAddTransaction != null
                        ? 'No transactions yet. Tap "${AppStrings.addTransaction}" above.'
                        : 'No transactions yet.',
                  )
                else
                  ...recent.map((item) {
                    final parsed = CategoryUtils.parseExpenseName(item.name);
                    return StitchTransactionTile(
                      title: parsed.title,
                      subtitle: CategoryUtils.formatTransactionSubtitle(
                        item.dateTime,
                      ),
                      category: parsed.category,
                      emoji: parsed.emoji,
                      amount: item.amount,
                      isIncome: item.type == 'income',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionPage(
                            initialItem: item,
                            itemIndex: value.getExpenseList().indexOf(item),
                            isEdit: true,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
