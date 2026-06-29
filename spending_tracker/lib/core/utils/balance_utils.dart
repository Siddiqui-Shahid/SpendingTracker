import '../../Model/Expense_item.dart';

/// Computes net balance from a list of income and expense transactions.
double calculateBalance(List<ExpenseItem> items) {
  var balance = 0.0;
  for (final item in items) {
    final amount = double.tryParse(item.amount) ?? 0.0;
    if (item.type == 'expense') {
      balance -= amount;
    } else {
      balance += amount;
    }
  }
  return balance;
}

/// Parses semantic version strings like `1.2.3` into a comparable integer.
/// Returns -1 for invalid input.
int parseVersionCode(String version) {
  if (version.trim().isEmpty) return -1;
  final parts = version.split('.');
  var code = 0;
  for (var i = 0; i < 3; i++) {
    final segment = i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0;
    code = code * 1000 + segment;
  }
  return code;
}
