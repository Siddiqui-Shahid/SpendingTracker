/// Data model for a single financial transaction (expense or income)
///
/// [ExpenseItem] represents a single financial transaction in the app.
/// It stores essential information about any money movement including
/// the description, date/time, amount, and whether it's income or expense.
///
/// This class is immutable and used throughout the app for:
/// - Displaying transaction information
/// - Storing data in Hive database
/// - State management via Provider
///
/// Example:
/// ```dart
/// final expense = ExpenseItem(
///   name: 'Grocery Shopping',
///   dateTime: DateTime.now(),
///   amount: '50.00',
///   type: 'expense',
/// );
/// ```

class ExpenseItem {
  /// The name or description of the transaction
  ///
  /// Examples:
  /// - "Grocery Shopping"
  /// - "Monthly Salary"
  /// - "Electricity Bill"
  /// - "Freelance Project Payment"
  final String name;

  /// The date and time when the transaction occurred
  ///
  /// Used for:
  /// - Sorting transactions chronologically
  /// - Displaying transaction history
  /// - Generating financial reports
  /// - Filtering by date range
  final DateTime dateTime;

  /// The amount of the transaction as a string
  ///
  /// Stored as string to preserve decimal precision.
  /// Contains only numeric values and optional decimal point.
  ///
  /// Examples:
  /// - "100.50"
  /// - "1000"
  /// - "0.99"
  final String amount;

  /// The type of transaction: either "income" or "expense"
  ///
  /// Valid values:
  /// - "income": Money coming in
  /// - "expense": Money going out
  ///
  /// Used for:
  /// - Categorizing transactions
  /// - Calculating balance (income adds, expense subtracts)
  /// - Filtering by transaction type
  /// - Visual differentiation in UI
  final String type;

  /// Creates an [ExpenseItem]
  ///
  /// All parameters are required and cannot be null.
  ///
  /// Parameters:
  /// - [name]: Description of the transaction
  /// - [dateTime]: When the transaction occurred
  /// - [amount]: The monetary amount
  /// - [type]: Either "income" or "expense"
  ///
  /// Example:
  /// ```dart
  /// ExpenseItem(
  ///   name: 'Coffee',
  ///   dateTime: DateTime.now(),
  ///   amount: '5.50',
  ///   type: 'expense',
  /// )
  /// ```
  ExpenseItem({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.type,
  });

  /// Returns the transaction type as a display string
  ///
  /// Can be extended for better localization support
  String getTypeDisplay() {
    switch (type.toLowerCase()) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      default:
        return type;
    }
  }

  /// Returns a string representation of the amount with currency symbol
  ///
  /// Example: "₹50.00", "\$100.50"
  /// Can be customized based on app settings
  String getFormattedAmount([String currency = '\$']) {
    return '$currency$amount';
  }

  /// Converts ExpenseItem to a map for database storage
  ///
  /// Used by Hive to serialize the object before storing
  Map<String, dynamic> toMap() {
    return {'name': name, 'dateTime': dateTime, 'amount': amount, 'type': type};
  }

  /// Creates an ExpenseItem from a map (database retrieval)
  ///
  /// Used by Hive to deserialize objects from database
  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      name: map['name'] ?? '',
      dateTime: map['dateTime'] ?? DateTime.now(),
      amount: map['amount'] ?? '0',
      type: map['type'] ?? 'expense',
    );
  }

  @override
  String toString() =>
      'ExpenseItem('
      'name: $name, '
      'dateTime: $dateTime, '
      'amount: $amount, '
      'type: $type)';
}
