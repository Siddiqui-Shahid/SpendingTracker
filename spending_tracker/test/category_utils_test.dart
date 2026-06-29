import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/core/utils/category_utils.dart';

void main() {
  group('CategoryUtils.parseExpenseName', () {
    test('parses emoji category and title', () {
      final result = CategoryUtils.parseExpenseName('🍔 Food - Lunch');
      expect(result.emoji, '🍔');
      expect(result.category, 'Food');
      expect(result.title, 'Lunch');
    });

    test('returns plain title when no separator', () {
      final result = CategoryUtils.parseExpenseName('Coffee');
      expect(result.category, isNull);
      expect(result.title, 'Coffee');
    });
  });

  group('CategoryUtils.extractCategory', () {
    test('extracts category label', () {
      expect(
        CategoryUtils.extractCategory('🛒 Groceries - Weekly shop'),
        'Groceries',
      );
    });

    test('falls back to Other', () {
      expect(CategoryUtils.extractCategory('Misc purchase'), 'Other');
    });
  });

  group('CategoryUtils.dateSectionLabel', () {
    test('labels today and yesterday', () {
      final now = DateTime(2026, 6, 29, 12);
      expect(
        CategoryUtils.dateSectionLabel(now, reference: now),
        'Today',
      );
      expect(
        CategoryUtils.dateSectionLabel(
          now.subtract(const Duration(days: 1)),
          reference: now,
        ),
        'Yesterday',
      );
    });
  });
}
