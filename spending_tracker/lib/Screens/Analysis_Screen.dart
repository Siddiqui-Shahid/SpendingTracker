import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../Data/Expense_data.dart';
import '../Model/Expense_item.dart';

/// Analysis Screen for visualizing spending patterns
///
/// This screen provides:
/// - Total spending overview
/// - Spending by category (pie chart)
/// - Spending trends over time
/// - Top spending categories list
/// - Time period filters (Week, Month, Year)
enum Period { week, month, year }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late Period selectedPeriod = Period.month;
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

  /// Set date range based on selected period
  void _setDateRange(Period period) {
    final now = DateTime.now();
    setState(() {
      selectedPeriod = period;
      switch (period) {
        case Period.week:
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
          break;
        case Period.month:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case Period.year:
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
  }

  /// Filter expenses by date range and type
  List<ExpenseItem> _getExpensesForPeriod(List<dynamic> allExpenses) {
    return allExpenses.whereType<ExpenseItem>().where((expense) {
      return expense.dateTime.isAfter(startDate) &&
          expense.dateTime.isBefore(endDate.add(const Duration(days: 1))) &&
          expense.type == 'expense';
    }).toList();
  }

  /// Calculate total spending
  double _calculateTotalSpending(List<ExpenseItem> expenses) {
    return expenses.fold<double>(
      0,
      (sum, expense) => sum + double.parse(expense.amount),
    );
  }

  /// Group expenses by category and calculate totals
  Map<String, double> _getSpendingByCategory(List<ExpenseItem> expenses) {
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = _extractCategory(expense.name);
      double amount = double.parse(expense.amount);

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }

  /// Extract category name from expense name
  String _extractCategory(String expenseName) {
    if (expenseName.contains(' - ')) {
      String category = expenseName.split(' - ')[0].trim();
      // Remove emoji if present
      if (category.contains(' ')) {
        category = category.substring(category.indexOf(' ') + 1);
      }
      return category;
    }
    return 'Other';
  }

  /// Get top 3 spending categories
  List<MapEntry<String, double>> _getTopCategories(
    Map<String, double> categoryTotals,
  ) {
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, expenseData, child) {
        final allExpenses = expenseData.getExpenseList();
        final periodExpenses = _getExpensesForPeriod(allExpenses);
        final totalSpending = _calculateTotalSpending(periodExpenses);
        final categoryTotals = _getSpendingByCategory(periodExpenses);
        final topCategories = _getTopCategories(categoryTotals);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            title: const Text('Analysis'),
            centerTitle: true,
            actions: [],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spending Card
                _buildTotalSpendingCard(totalSpending),

                // Period Filter Buttons
                _buildPeriodFilter(),
                const SizedBox(height: 4), // add a small gap only
                // Charts Section (vertical layout)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Spending by Category (pie)
                      _buildCategoryPieChart(categoryTotals, totalSpending),
                    ],
                  ),
                ),

                // Top Spending Categories
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Spending Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
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

  /// Build total spending card
  Widget _buildTotalSpendingCard(double totalSpending) {
    // Calculate total earning for the period
    final expenseData = Provider.of<ExpenseData>(context, listen: false);
    final allExpenses = expenseData.getExpenseList();
    final earnings = allExpenses.whereType<ExpenseItem>().where((item) {
      return item.dateTime.isAfter(startDate) &&
          item.dateTime.isBefore(endDate.add(const Duration(days: 1))) &&
          item.type == 'income';
    }).toList();
    final totalEarning = earnings.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.amount) ?? 0.0),
    );

    String periodLabel = selectedPeriod == Period.week
        ? 'This Week'
        : selectedPeriod == Period.month
        ? 'This Month'
        : 'This Year';

    final netResult = totalEarning - totalSpending;
    final netColor = netResult >= 0 ? Colors.blue : Colors.red;
    final netPrefix = netResult >= 0 ? '+' : '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              periodLabel,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _spendingColumn(
                  icon: Icons.arrow_downward,
                  label: 'Spent',
                  value: '-\$${totalSpending.toStringAsFixed(2)}',
                  color: Colors.red,
                  iconBg: Colors.red.withOpacity(0.09),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.grey.withOpacity(0.15),
                ),
                _spendingColumn(
                  icon: Icons.arrow_upward,
                  label: 'Earned',
                  value: '+\$${totalEarning.toStringAsFixed(2)}',
                  color: Colors.blue,
                  iconBg: Colors.blue.withOpacity(0.09),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: netColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    netResult >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: netColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Net: $netPrefix\$${netResult.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: netColor,
                      letterSpacing: -0.5,
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

  Widget _spendingColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconBg,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build period filter chips
  Widget _buildPeriodFilter() {
    final periods = Period.values;
    String periodToString(Period p) {
      switch (p) {
        case Period.week:
          return 'Week';
        case Period.month:
          return 'Month';
        case Period.year:
          return 'Year';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          ...periods.map((period) {
            final isSelected = selectedPeriod == period && !isCustomSelected;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  periodToString(period),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.blue.withOpacity(0.10),
                backgroundColor: Colors.transparent,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.blue,
                    width: 1.2,
                  ),
                ),
                onSelected: (selected) {
                  if (!isSelected) {
                    setState(() {
                      isCustomSelected = false;
                      customLabel = null;
                    });
                    _setDateRange(period);
                  }
                },
                showCheckmark: false,
                elevation: 0,
                pressElevation: 0,
              ),
            );
          }),
          // Custom chip
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                customLabel ?? 'Custom',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              selected: isCustomSelected,
              selectedColor: Colors.blue.withOpacity(0.10),
              backgroundColor: Colors.transparent,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isCustomSelected ? Colors.blue : Colors.blue,
                  width: 1.2,
                ),
              ),
              onSelected: (selected) async {
                // Always allow editing the custom range when the chip is tapped,
                // even if it's already selected. The dialog's Apply button
                // controls whether the chip becomes/remains selected and the
                // label is updated.
                await _showCustomDateRangeDialog();
              },
              showCheckmark: false,
              elevation: 0,
              pressElevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDateRangeDialog() async {
    DateTime? tempStart = customStartDate;
    DateTime? tempEnd = customEndDate;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      tempStart == null
                          ? 'Select Start Date'
                          : 'Start: 	${tempStart!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempStart ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: tempEnd ?? DateTime(2100),
                        selectableDayPredicate: (date) {
                          if (tempEnd != null) {
                            return !date.isAfter(tempEnd!);
                          }
                          return true;
                        },
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          tempStart = picked;
                          if (tempEnd != null &&
                              tempEnd!.isBefore(tempStart!)) {
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
                          : 'End:   ${tempEnd!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempEnd ?? (tempStart ?? DateTime.now()),
                        firstDate: tempStart ?? DateTime(2000),
                        lastDate: DateTime(2100),
                        selectableDayPredicate: (date) {
                          if (tempStart != null) {
                            return !date.isBefore(tempStart!);
                          }
                          return true;
                        },
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          tempEnd = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (tempStart != null && tempEnd != null)
                      ? () {
                          setState(() {
                            isCustomSelected = true;
                            customStartDate = tempStart;
                            customEndDate = tempEnd;
                            startDate = customStartDate!;
                            endDate = customEndDate!;
                            selectedPeriod = Period.month; // dummy, not used
                            customLabel =
                                '${customStartDate!.toLocal().toString().split(' ')[0]} - ${customEndDate!.toLocal().toString().split(' ')[0]}';
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Build pie chart for category spending
  Widget _buildCategoryPieChart(
    Map<String, double> categoryTotals,
    double totalSpending,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending by Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [_buildSimplePieChart(categoryTotals)],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '\$${totalSpending.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build simple pie chart visualization
  Widget _buildSimplePieChart(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);
    // More visually distinct palette
    final colors = [
      const Color(0xff1f77b4), // blue
      const Color(0xff2ca02c), // green
      const Color(0xffff7f0e), // orange
      const Color(0xffd62728), // red
      const Color(0xff9467bd), // purple
      const Color(0xff8c564b), // brown
      const Color(0xffe377c2), // pink
      const Color(0xff17becf), // teal
      const Color(0xffffc107), // amber
      const Color(0xff7f7f7f), // gray
    ];

    int colorIndex = 0;

    return CustomPaint(
      painter: SimplePiePainter(
        slices: categoryTotals.entries
            .map(
              (entry) => PieSlice(
                angle: (entry.value / total) * 360,
                color: colors[colorIndex++ % colors.length],
              ),
            )
            .toList(),
      ),
      size: const Size(150, 150),
    );
  }

  /// Build top categories list
  List<Widget> _buildTopCategoriesList(
    List<MapEntry<String, double>> topCategories,
    double totalSpending,
  ) {
    return topCategories.map((entry) {
      final percentage = totalSpending > 0
          ? (entry.value / totalSpending) * 100
          : 0;
      final iconMap = {
        'Shopping': Icons.shopping_cart,
        'Food': Icons.restaurant,
        'Bills': Icons.receipt_long,
        'Education': Icons.school,
        'Travel': Icons.flight_takeoff,
        'Entertainment': Icons.movie,
        'Health': Icons.local_hospital,
        'Groceries': Icons.shopping_basket,
        'Miscellaneous': Icons.category,
      };

      final icon = iconMap[entry.key] ?? Icons.category;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff0d7ff2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xff0d7ff2), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of spending',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

/// Simple pie chart painter
class SimplePiePainter extends CustomPainter {
  final List<PieSlice> slices;

  SimplePiePainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Start at top (-90 degrees)
    double currentAngle = -math.pi / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final slice in slices) {
      paint.color = slice.color;
      final sweep = slice.angle * (math.pi / 180);
      canvas.drawArc(rect, currentAngle, sweep, true, paint);
      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(SimplePiePainter oldDelegate) => true;
}

/// Pie slice model
class PieSlice {
  final double angle;
  final Color color;

  PieSlice({required this.angle, required this.color});
}
