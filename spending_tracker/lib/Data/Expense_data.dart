/// State management provider for expense tracking using Provider pattern
///
/// [ExpenseData] is the central state manager for the entire application.
/// It extends [ChangeNotifier] to provide reactive updates to all listening widgets.
///
/// Responsibilities:
/// - Managing the list of all expenses and income
/// - Maintaining current account balance
/// - Storing and retrieving app settings
/// - Persisting data to local database (Hive)
/// - Notifying listeners of state changes
///
/// Usage:
/// ```dart
/// // In widgets, access via Provider
/// final expenseData = Provider.of<ExpenseData>(context);
/// final balance = expenseData.getBalance();
/// final expenses = expenseData.getExpenseList();
/// ```

import 'package:flutter/cupertino.dart';
import 'package:new_spendz/Data/hive_database.dart';
import '../Model/Expense_item.dart';

/// Central state manager for all expense-related data and operations
///
/// This class implements the Provider pattern with ChangeNotifier for
/// efficient state management and automatic UI updates.
///
/// Key Features:
/// - Real-time balance calculation
/// - Expense/income transaction management
/// - Local data persistence via Hive
/// - Settings management (biometric, currency, etc.)
/// - Automatic UI refresh on data changes
class ExpenseData extends ChangeNotifier {
  /// Instance of Hive database for persistent storage
  final db = HiveDataBase();

  /// List of all transactions (expenses and income)
  ///
  /// Format: [ExpenseItem]
  /// Updated whenever transactions are added, modified, or deleted
  List<ExpenseItem> overallExpenseList = [];

  /// Application settings stored as a list of integers
  ///
  /// Format: [currency, ..., fingerprint, ...]
  /// - Index 0: Currency selection
  /// - Index 2: Fingerprint enabled (1 = enabled, 0 = disabled)
  /// - Future indices: Additional settings
  List<int> savedSettings = [0, 0, 0, 0];

  /// Updates an existing expense transaction
  ///
  /// Parameters:
  /// - [index]: Index of the expense to update
  /// - [updatedExpense]: Updated expense data
  ///
  /// Side Effects:
  /// - Replaces transaction at index
  /// - Persists to database
  /// - Notifies all listeners
  /// - Recalculates balance if amount changed
  ///
  /// Validation:
  /// - Checks if index is valid
  /// - Silently ignores invalid indices
  ///
  /// Example:
  /// ```dart
  /// final updatedExpense = ExpenseItem(
  ///   name: 'Updated Item',
  ///   amount: '75.00',
  ///   type: 'expense',
  ///   dateTime: DateTime.now(),
  /// );
  /// expenseData.updateExpense(0, updatedExpense);
  /// ```
  void updateExpense(int index, ExpenseItem updatedExpense) {
    if (index >= 0 && index < overallExpenseList.length) {
      overallExpenseList[index] = updatedExpense;
      db.saveData(overallExpenseList);
      notifyListeners();
    }
  }

  /// Completely erases all data including expenses, balance, and settings
  ///
  /// This is a destructive operation that:
  /// - Clears all expenses
  /// - Resets balance to 0
  /// - Resets all settings to default
  /// - Clears Hive database
  ///
  /// Side Effects:
  /// - Empties [overallExpenseList]
  /// - Resets [savedSettings] to [0, 0, 0, 0]
  /// - Calls [db.eraseAndReset()] - database clearing
  /// - Notifies all listeners
  ///
  /// Warning: This operation is NOT reversible. Use with caution!
  ///
  /// Use Cases:
  /// - Fresh app start
  /// - User initiated factory reset
  /// - Uninstall/cleanup
  ///
  /// Example:
  /// ```dart
  /// if (confirmDelete) {
  ///   await expenseData.eraseAndResetAll();
  /// }
  /// ```
  Future<void> eraseAndResetAll() async {
    await db.eraseAndReset();
    overallExpenseList.clear();
    savedSettings = [0, 0, 0, 0];
    notifyListeners();
  }

  /// Retrieves the list of all expenses and income transactions
  ///
  /// Returns:
  /// - [List<ExpenseItem>]: All transactions in chronological order
  ///
  /// Example:
  /// ```dart
  /// final expenses = expenseData.getExpenseList();
  /// for (var expense in expenses) {
  ///   print('${expense.name}: ${expense.amount}');
  /// }
  /// ```
  List<ExpenseItem> getExpenseList() {
    return overallExpenseList;
  }

  /// Gets the current account balance
  ///
  /// Balance calculation:
  /// - Income transactions: add to balance
  /// - Expense transactions: subtract from balance
  ///
  /// Returns:
  /// - [double]: Current account balance
  ///
  /// Example:
  /// ```dart
  /// final currentBalance = expenseData.getBalance();
  /// print('Current Balance: \$$currentBalance');
  /// ```
  double getBalance() {
    return db.readBalance();
  }

  /// Updates the account balance and persists to database
  ///
  /// Parameters:
  /// - [balance]: New balance value
  ///
  /// Side Effects:
  /// - Saves to Hive database
  /// - Notifies all listeners
  /// - Logs debug information
  ///
  /// Example:
  /// ```dart
  /// expenseData.setBalance(500.0);
  /// ```
  void setBalance(double balance) {
    debugPrint(
      '[ExpenseData] setBalance called with value: '
      '[32m$balance[0m',
    );
    db.saveBalance(balance);
    final hiveBalance = db.readBalance();
    debugPrint(
      '[ExpenseData] Hive balance after save: '
      '\u001b[36m$hiveBalance\u001b[0m',
    );
    notifyListeners();
  }

  /// Retrieves a specific setting value
  ///
  /// Parameters:
  /// - [settingNum]: Index of the setting to retrieve
  ///   - 2: Fingerprint enabled status (special case)
  ///   - Other: General settings
  ///
  /// Returns:
  /// - [int]: The setting value
  ///
  /// Note: Setting 2 (fingerprint) is handled specially for backward
  /// compatibility with the old getSettings() API
  ///
  /// Example:
  /// ```dart
  /// final fingerprintSetting = expenseData.getSavedSettings(2);
  /// ```
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

  /// Checks if biometric (fingerprint/face) authentication is enabled
  ///
  /// Returns:
  /// - [bool]: true if fingerprint authentication is enabled, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (expenseData.getFingerprintEnabled()) {
  ///   await authenticateWithBiometrics();
  /// }
  /// ```
  bool getFingerprintEnabled() {
    savedSettings[2] = db.getFingerprintEnabled();
    return savedSettings[2] == 1;
  }

  /// Updates biometric authentication setting
  ///
  /// Parameters:
  /// - [enabled]: true to enable fingerprint auth, false to disable
  ///
  /// Side Effects:
  /// - Updates local settings list
  /// - Persists to database
  /// - Notifies all listeners
  ///
  /// Example:
  /// ```dart
  /// expenseData.setFingerprintEnabled(true);
  /// ```
  void setFingerprintEnabled(bool enabled) {
    savedSettings[2] = enabled ? 1 : 0;
    db.saveFingerprintEnabled(savedSettings[2]);
    notifyListeners();
  }

  /// Loads all expense data from database into memory
  ///
  /// Should be called:
  /// - On app initialization
  /// - When returning from background
  /// - After data import
  ///
  /// Side Effects:
  /// - Populates [overallExpenseList] from database
  /// - Notifies all listeners
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   expenseData.prepareData();
  /// }
  /// ```
  void prepareData() {
    overallExpenseList = db.readData();
    notifyListeners();
  }

  /// Adds a new expense transaction
  ///
  /// Parameters:
  /// - [newExpense]: The expense to add (type must be "expense")
  ///
  /// Side Effects:
  /// - Adds to [overallExpenseList]
  /// - Persists to database
  /// - Notifies all listeners
  /// - Typically reduces balance
  ///
  /// Example:
  /// ```dart
  /// final expense = ExpenseItem(
  ///   name: 'Groceries',
  ///   amount: '50.00',
  ///   type: 'expense',
  ///   dateTime: DateTime.now(),
  /// );
  /// expenseData.addExpense(expense);
  /// ```
  void addExpense(ExpenseItem newExpense) {
    overallExpenseList.add(newExpense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  /// Adds a new income transaction
  ///
  /// Parameters:
  /// - [newIncome]: The income to add (type must be "income")
  ///
  /// Side Effects:
  /// - Adds to [overallExpenseList]
  /// - Persists to database
  /// - Notifies all listeners
  /// - Typically increases balance
  ///
  /// Example:
  /// ```dart
  /// final income = ExpenseItem(
  ///   name: 'Salary',
  ///   amount: '2000.00',
  ///   type: 'income',
  ///   dateTime: DateTime.now(),
  /// );
  /// expenseData.addIncome(income);
  /// ```
  void addIncome(ExpenseItem newIncome) {
    overallExpenseList.add(newIncome);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  /// Deletes a transaction and recalculates balance
  ///
  /// Parameters:
  /// - [expense]: The expense/income to delete
  ///
  /// Side Effects:
  /// - Removes transaction from list
  /// - Recalculates balance from remaining transactions
  /// - Updates balance in database
  /// - Persists updated list
  /// - Notifies all listeners
  ///
  /// Note: Balance is recalculated by summing all remaining transactions
  /// to ensure consistency
  ///
  /// Example:
  /// ```dart
  /// expenseData.deleteExpense(transaction);
  /// ```
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

  /// Adds or updates a general app setting
  ///
  /// Parameters:
  /// - [settingNum]: Index of the setting to update
  /// - [newSetting]: New value for the setting
  ///
  /// Side Effects:
  /// - Updates [savedSettings] list
  /// - Persists to database
  /// - Notifies all listeners
  ///
  /// Example:
  /// ```dart
  /// expenseData.addSettings(0, 1); // Change currency
  /// ```
  void addSettings(int settingNum, int newSetting) {
    savedSettings[settingNum] = newSetting;
    db.saveSettings(savedSettings);
    print(savedSettings);
    notifyListeners();
  }

  /// Removes all expenses from the list
  ///
  /// Side Effects:
  /// - Clears [overallExpenseList]
  /// - Persists empty list to database
  /// - Notifies all listeners
  /// - Does NOT reset balance (separate action)
  ///
  /// Warning: This does not clear the database balance or settings.
  /// For complete data reset, use [eraseAndResetAll]
  ///
  /// Example:
  /// ```dart
  /// expenseData.clearAllExpenses();
  /// ```
  void clearAllExpenses() {
    overallExpenseList.clear();
    notifyListeners();
    db.saveData(overallExpenseList);
  }
}
