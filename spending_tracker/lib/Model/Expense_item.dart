class ExpenseItem {
  final String name;
  final DateTime dateTime;
  final String amount;
  final String type; // "income" or "expense"

  ExpenseItem({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.type,
  });
}
