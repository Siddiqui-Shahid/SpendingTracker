import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/core/analytics/analytics_filter.dart';

ExpenseItem _item({
  required String name,
  required String amount,
  required String type,
  DateTime? date,
}) {
  return ExpenseItem(
    name: name,
    amount: amount,
    type: type,
    dateTime: date ?? DateTime(2026, 8, 1),
  );
}

void main() {
  final items = [
    _item(name: '🍔 Food - Lunch', amount: '15', type: 'expense'),
    _item(name: '🍔 Food - Dinner', amount: '45', type: 'expense'),
    _item(name: '✈️ Travel - Cab', amount: '120', type: 'expense'),
    _item(name: '💰 Salary - August', amount: '1000', type: 'income'),
  ];

  group('AnalyticsFilter', () {
    test('filters by expense type', () {
      const filter = AnalyticsFilter(type: AnalyticsTxnType.expense);
      final result = filter.apply(items);
      expect(result.every((e) => e.type == 'expense'), isTrue);
      expect(result.length, 3);
    });

    test('filters amount under 20', () {
      const filter = AnalyticsFilter(
        amountPreset: AnalyticsAmountPreset.under20,
      );
      final result = filter.apply(items);
      expect(result.map((e) => e.amount), ['15']);
    });

    test('filters by label query', () {
      const filter = AnalyticsFilter(labelQuery: 'lunch');
      final result = filter.apply(items);
      expect(result.single.name, contains('Lunch'));
    });

    test('filters by multiple categories', () {
      const filter = AnalyticsFilter(
        categories: {'🍔 Food', '✈️ Travel'},
      );
      final result = filter.apply(items);
      expect(result.length, 3);
      expect(result.any((e) => e.type == 'income'), isFalse);
    });

    test('combines type, amount, and category', () {
      const filter = AnalyticsFilter(
        type: AnalyticsTxnType.expense,
        amountPreset: AnalyticsAmountPreset.under50,
        categories: {'🍔 Food'},
      );
      final result = filter.apply(items);
      expect(result.length, 2);
      expect(result.every((e) => e.name.contains('Food')), isTrue);
    });
  });
}
