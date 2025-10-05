import 'package:flutter/cupertino.dart';
import 'package:new_spendz/Data/hive_database.dart';
import '../Model/Expense_item.dart';

class ExpenseData extends ChangeNotifier {
  void updateExpense(int index, ExpenseItem updatedExpense) {
    if (index >= 0 && index < overallExpenseList.length) {
      overallExpenseList[index] = updatedExpense;
      db.saveData(overallExpenseList);
      notifyListeners();
    }
  }

  Future<void> eraseAndResetAll() async {
    await db.eraseAndReset();
    overallExpenseList.clear();
    savedSettings = [0, 0, 0, 0];
    notifyListeners();
  }

  final db = HiveDataBase();

  List<ExpenseItem> overallExpenseList = [];
  List<int> savedSettings = [0, 0, 0, 0]; // [currency, ..., fingerprint, ...]

  List<ExpenseItem> getExpenseList() {
    return overallExpenseList;
  }

  double getBalance() {
    return db.readBalance();
  }

  void setBalance(double balance) {
    db.saveBalance(balance);
    notifyListeners();
  }

  int getSavedSettings(int settingNum) {
    // For backward compatibility, getSettings() returns int, but we want a list
    // So, if you want to store more settings, use a list in Hive
    if (settingNum == 2) {
      // fingerprint setting
      savedSettings[2] = db.getFingerprintEnabled();
      return savedSettings[2];
    } else {
      savedSettings[settingNum] = db.getSettings();
      print(db.getSettings());
      return savedSettings[settingNum];
    }
  }

  bool getFingerprintEnabled() {
    savedSettings[2] = db.getFingerprintEnabled();
    return savedSettings[2] == 1;
  }

  void setFingerprintEnabled(bool enabled) {
    savedSettings[2] = enabled ? 1 : 0;
    db.saveFingerprintEnabled(savedSettings[2]);
    notifyListeners();
  }

  void prepareData() {
    if (db.readData().isNotEmpty) {
      overallExpenseList = db.readData();
    }
  }

  void addExpense(ExpenseItem newExpense) {
    overallExpenseList.add(newExpense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  void addIncome(ExpenseItem newIncome) {
    overallExpenseList.add(newIncome);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  void deleteExpense(ExpenseItem expense) {
    // Remove the expense
    overallExpenseList.remove(expense);
    // Recalculate balance
    double balance = 0.0;
    for (var item in overallExpenseList) {
      double amt = double.tryParse(item.amount) ?? 0.0;
      if (item.type == 'expense') {
        balance -= amt;
      } else {
        balance += amt;
      }
    }
    db.saveData(overallExpenseList);
    db.saveBalance(balance);
    notifyListeners();
  }

  void addSettings(int settingNum, int newSetting) {
    savedSettings[settingNum] = newSetting;
    db.saveSettings(savedSettings);
    print(savedSettings);
    notifyListeners();
  }

  void clearAllExpenses() {
    overallExpenseList.clear();
    notifyListeners();
    db.saveData(overallExpenseList);
  }
}
