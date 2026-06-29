import '../Model/Expense_item.dart';

/// Generates realistic sample transactions spanning [monthCount] months
/// ending at [endDate].
List<ExpenseItem> generateSampleTransactions({
  required DateTime endDate,
  int monthCount = 10,
}) {
  final startMonth = DateTime(endDate.year, endDate.month - (monthCount - 1), 1);
  final transactions = <ExpenseItem>[];

  final expenseTemplates = [
    ('🛒 Groceries', 'Weekly groceries', 850, 2200),
    ('🍔 Food', 'Lunch', 120, 450),
    ('🍔 Food', 'Dinner out', 350, 1200),
    ('🍔 Food', 'Coffee', 80, 220),
    ('💡 Bills', 'Electricity bill', 800, 1800),
    ('💡 Bills', 'Internet', 599, 899),
    ('💡 Bills', 'Mobile recharge', 299, 599),
    ('🛍️ Shopping', 'Clothing', 500, 3500),
    ('🎬 Entertainment', 'Movie tickets', 300, 800),
    ('🎬 Entertainment', 'Streaming subscription', 199, 299),
    ('✈️ Travel', 'Cab ride', 150, 600),
    ('💊 Health', 'Pharmacy', 200, 900),
    ('🎓 Education', 'Online course', 499, 1999),
    ('📦 Miscellaneous', 'Household items', 150, 700),
    ('🎁 Gifts', 'Birthday gift', 500, 2500),
  ];

  final incomeTemplates = [
    ('Salary', 'Monthly salary', 52000, 58000),
    ('Freelance', 'Side project payment', 3000, 12000),
  ];

  var month = DateTime(startMonth.year, startMonth.month, 1);
  final lastMonth = DateTime(endDate.year, endDate.month, 1);
  var seed = endDate.millisecondsSinceEpoch;

  int nextInt(int min, int max) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return min + seed % (max - min + 1);
  }

  double nextAmount(int min, int max) {
    return nextInt(min, max).toDouble();
  }

  DateTime dayInMonth(DateTime m, int day) {
    final lastDay = DateTime(m.year, m.month + 1, 0).day;
    final safeDay = day.clamp(1, lastDay);
    return DateTime(m.year, m.month, safeDay, nextInt(8, 20), nextInt(0, 59));
  }

  while (!month.isAfter(lastMonth)) {
    final isCurrentMonth =
        month.year == endDate.year && month.month == endDate.month;

    // Monthly salary on the 1st
    final salaryAmount = nextAmount(52000, 58000);
    transactions.add(
      ExpenseItem(
        name: '💼 Income - Monthly salary',
        dateTime: dayInMonth(month, 1),
        amount: salaryAmount.toStringAsFixed(0),
        type: 'income',
      ),
    );

    // Occasional freelance income
    if (nextInt(0, 2) == 0) {
      final freelanceAmount = nextAmount(3000, 12000);
      transactions.add(
        ExpenseItem(
          name: '📦 Income - ${incomeTemplates[1].$2}',
          dateTime: dayInMonth(month, nextInt(10, 25)),
          amount: freelanceAmount.toStringAsFixed(0),
          type: 'income',
        ),
      );
    }

    // Rent on the 5th
    transactions.add(
      ExpenseItem(
        name: '💡 Bills - Rent',
        dateTime: dayInMonth(month, 5),
        amount: '15000',
        type: 'expense',
      ),
    );

    // 8-14 random expenses per month
    final expenseCount = isCurrentMonth ? nextInt(4, 8) : nextInt(8, 14);
    for (var i = 0; i < expenseCount; i++) {
      final template = expenseTemplates[nextInt(0, expenseTemplates.length - 1)];
      final amount = nextAmount(template.$3, template.$4);
      var day = nextInt(1, isCurrentMonth ? endDate.day : 28);
      if (isCurrentMonth && day > endDate.day) {
        day = endDate.day;
      }
      transactions.add(
        ExpenseItem(
          name: '${template.$1} - ${template.$2}',
          dateTime: dayInMonth(month, day),
          amount: amount.toStringAsFixed(0),
          type: 'expense',
        ),
      );
    }

    month = DateTime(month.year, month.month + 1, 1);
  }

  transactions.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return transactions;
}
