import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/Model/Expense_item.dart';

void main() {
  group('backup JSON round-trip', () {
    test('parses expenses from backup format', () {
      final backup = {
        'expenses': [
          {
            'name': '🍔 Food - Lunch',
            'amount': '120',
            'date': '2026-06-01T12:00:00.000',
            'type': 'expense',
          },
          {
            'name': 'Salary',
            'amount': '50000',
            'date': '2026-06-01T09:00:00.000',
            'type': 'income',
          },
        ],
        'balance': 49880.0,
        'categories': ['🍔 Food'],
      };

      final decoded = jsonDecode(jsonEncode(backup)) as Map<String, dynamic>;
      final expenses = <ExpenseItem>[];

      for (final e in decoded['expenses'] as List) {
        expenses.add(
          ExpenseItem(
            name: e['name'] as String,
            amount: e['amount'].toString(),
            dateTime: DateTime.parse(e['date'] as String),
            type: e['type'] as String,
          ),
        );
      }

      expect(expenses, hasLength(2));
      expect(expenses.first.type, 'expense');
      expect(expenses.last.type, 'income');
      expect(decoded['balance'], 49880.0);
    });
  });
}
