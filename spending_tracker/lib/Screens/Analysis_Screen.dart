import 'package:flutter/material.dart';
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
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late String selectedPeriod = 'Month';
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    _setDateRange('Month');
  }

  /// Set date range based on selected period
  void _setDateRange(String period) {
    final now = DateTime.now();
    selectedPeriod = period;

    switch (period) {
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
    }
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

  /// Get spending by week
  Map<String, double> _getSpendingByWeek(List<ExpenseItem> expenses) {
    Map<String, double> weeklyTotals = {};
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    for (int week = 1; week <= 4; week++) {
      final weekStart = startOfMonth.add(Duration(days: (week - 1) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekExpenses = expenses.where((expense) {
        return expense.dateTime.isAfter(weekStart) &&
            expense.dateTime.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();

      final weekTotal = _calculateTotalSpending(weekExpenses);
      weeklyTotals['Week $week'] = weekTotal;
    }

    return weeklyTotals;
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
        final weeklySpending = _getSpendingByWeek(periodExpenses);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            title: const Text('Dashboard'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spending Card
                _buildTotalSpendingCard(totalSpending),

                // Period Filter Buttons
                _buildPeriodFilter(),

                // Charts Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Pie Chart
                      Expanded(
                        child: _buildCategoryPieChart(
                          categoryTotals,
                          totalSpending,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Spending Trends
                      Expanded(
                        child: _buildSpendingTrends(weeklySpending),
                      ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${totalSpending.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xff0d7ff2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Total Spending for This Period',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build period filter buttons
  Widget _buildPeriodFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPeriodButton('Week'),
          const SizedBox(width: 12),
          _buildPeriodButton('Month'),
          const SizedBox(width: 12),
          _buildPeriodButton('Year'),
        ],
      ),
    );
  }

  /// Build individual period button
  Widget _buildPeriodButton(String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _setDateRange(period);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff0d7ff2).withOpacity(0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              period,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xff0d7ff2)
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              color: isSelected
                  ? const Color(0xff0d7ff2)
                  : Colors.grey[700],
              size: 20,
            ),
          ],
        ),
      ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildSimplePieChart(categoryTotals),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
                ],
              ),
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
    final colors = [
      const Color(0xff0d7ff2),
      const Color(0xff64b5f6),
      const Color(0xffc8e6f5),
      const Color(0xffd1d5db),
    ];

    int colorIndex = 0;
    double currentAngle = -90;

    return CustomPaint(
      painter: SimplePiePainter(
        slices: categoryTotals.entries
            .map((entry) => PieSlice(
              angle: (entry.value / total) * 360,
              color: colors[colorIndex++ % colors.length],
            ))
            .toList(),
      ),
      size: const Size(150, 150),
    );
  }

  /// Build spending trends chart
  Widget _buildSpendingTrends(Map<String, double> weeklySpending) {
    final maxValue = weeklySpending.values.isNotEmpty
        ? weeklySpending.values.reduce((a, b) => a > b ? a : b)
        : 100;

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
            'Spending Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weeklySpending.entries.map((entry) {
                final percentage =
                    maxValue > 0 ? (entry.value / maxValue) * 100 : 0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: (percentage / 100) * 150,
                      decoration: BoxDecoration(
                        color: const Color(0xff0d7ff2).withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key.replaceFirst('Week ', 'W'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build top categories list
  List<Widget> _buildTopCategoriesList(
    List<MapEntry<String, double>> topCategories,
    double totalSpending,
  ) {
    return topCategories.map((entry) {
      final percentage =
          totalSpending > 0 ? (entry.value / totalSpending) * 100 : 0;
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
                child: Icon(
                  icon,
                  color: const Color(0xff0d7ff2),
                  size: 24,
                ),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
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
    final paint = Paint()..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    double currentAngle = -90;

    for (final slice in slices) {
      paint.color = slice.color;
      paint.strokeWidth = 12;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        currentAngle * (3.141592653589793 / 180),
        slice.angle * (3.141592653589793 / 180),
        false,
        paint,
      );

      currentAngle += slice.angle;
    }
  }

  @override
  bool shouldRepaint(SimplePiePainter oldDelegate) => false;
}

/// Pie slice model
class PieSlice {
  final double angle;
  final Color color;

  PieSlice({required this.angle, required this.color});
}
