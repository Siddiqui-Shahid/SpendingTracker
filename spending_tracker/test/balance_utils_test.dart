import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/core/utils/balance_utils.dart';

void main() {
  group('calculateBalance', () {
    test('sums income and subtracts expenses', () {
      final items = [
        ExpenseItem(
          name: 'Salary',
          amount: '5000',
          dateTime: DateTime(2026, 1, 1),
          type: 'income',
        ),
        ExpenseItem(
          name: 'Rent',
          amount: '1500',
          dateTime: DateTime(2026, 1, 2),
          type: 'expense',
        ),
        ExpenseItem(
          name: 'Food',
          amount: '250.50',
          dateTime: DateTime(2026, 1, 3),
          type: 'expense',
        ),
      ];

      expect(calculateBalance(items), closeTo(3249.5, 0.001));
    });

    test('returns zero for empty list', () {
      expect(calculateBalance([]), 0);
    });

    test('ignores invalid amounts', () {
      final items = [
        ExpenseItem(
          name: 'Bad',
          amount: 'not-a-number',
          dateTime: DateTime.now(),
          type: 'expense',
        ),
      ];
      expect(calculateBalance(items), 0);
    });
  });

  group('parseVersionCode', () {
    test('compares semantic versions', () {
      expect(parseVersionCode('1.0.0'), lessThan(parseVersionCode('1.0.1')));
      expect(parseVersionCode('1.2.0'), lessThan(parseVersionCode('2.0.0')));
      expect(parseVersionCode('1.10.0'), greaterThan(parseVersionCode('1.9.0')));
    });

    test('returns -1 for empty string', () {
      expect(parseVersionCode(''), -1);
    });
  });
}
