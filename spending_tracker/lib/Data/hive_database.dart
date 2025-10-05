import 'package:hive_flutter/hive_flutter.dart';
import '../Model/Expense_item.dart';

class HiveDataBase {
  // Erase all data and reset to defaults
  Future<void> eraseAndReset() async {
    await _myBox.clear();
    // Set default categories
    await _myBox.put("Category", [
      '🎓 Education',
      '🍔 Food',
      '✈️ Travel',
      '📦 Miscellaneous',
      '💊 Health',
      '🛍️ Shopping',
      '💡 Bills',
      '🎬 Entertainment',
      '🛒 Groceries',
      '🎁 Gifts',
    ]);
    // Set default balance
    await _myBox.put("Balance", 0.0);
    // Set default settings (adjust as needed)
    await _myBox.put("Settings", 0);
    await _myBox.put("FingerprintEnabled", 0);
    // Remove all expenses
    await _myBox.put("All Expenses", []);
  }

  // Save fingerprint setting (0 or 1)
  void saveFingerprintEnabled(int enabled) {
    _myBox.put("FingerprintEnabled", enabled);
  }

  // Get fingerprint setting (0 or 1)
  int getFingerprintEnabled() {
    return _myBox.get("FingerprintEnabled") ?? 0;
  }

  final _myBox = Hive.box("expense_database");

  void saveData(List<ExpenseItem> allExpense) {
    List<List<dynamic>> allExpensesFormatted = [];

    for (var expense in allExpense) {
      List<dynamic> expenseFormatted = [
        expense.name,
        expense.amount,
        expense.dateTime,
        expense.type,
      ];
      allExpensesFormatted.add(expenseFormatted);
    }
    //storing the hive box
    _myBox.put("All Expenses", allExpensesFormatted);
  }

  void saveBalance(double balance) {
    _myBox.put("Balance", balance);
  }

  void saveSettings(List<int> newSettings) {
    _myBox.put("Settings", newSettings[0]);
  }

  int getSettings() {
    return _myBox.get("Settings") ?? 0;
  }

  double readBalance() {
    return _myBox.get("Balance") ??
        0.0; // Default to 0.0 if no balance is stored.
  }

  void setCategory(List<String> avlbC) {
    _myBox.put("Category", avlbC);
  }

  List<String> getCategory() {
    return _myBox.get("Category") ?? <String>[];
  }

  List<ExpenseItem> readData() {
    List savedExpenses = _myBox.get("All Expenses") ?? [];
    List<ExpenseItem> allExpenses = [];
    for (int i = 0; i < savedExpenses.length; i++) {
      String name = savedExpenses[i][0];
      String amount = savedExpenses[i][1];
      DateTime dateTime = savedExpenses[i][2];
      String type = savedExpenses[i].length > 3
          ? savedExpenses[i][3]
          : "expense";

      ExpenseItem expense = ExpenseItem(
        name: name,
        dateTime: dateTime,
        amount: amount,
        type: type,
      );
      allExpenses.add(expense);
    }
    return allExpenses;
  }
}
