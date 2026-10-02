import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/core/voice/voice_transaction_parser.dart';

void main() {
  const known = [
    '🎓 Education',
    '🍔 Food',
    '✈️ Travel',
    '🛒 Groceries',
  ];

  final now = DateTime(2026, 8, 3, 12);

  group('VoiceTransactionParser', () {
    test('parses full expense phrase with title and month name date', () {
      final draft = VoiceTransactionParser.parse(
        'expense amount 250 title lunch date 3 March category Food',
        now: now,
        knownCategories: known,
      );

      expect(draft.type, VoiceTransactionType.expense);
      expect(draft.amount, 250);
      expect(draft.title, 'lunch');
      expect(draft.date, DateTime(2026, 3, 3));
      expect(draft.category, '🍔 Food');
      expect(draft.noCategory, isFalse);
    });

    test('parses income with numeric date format', () {
      final draft = VoiceTransactionParser.parse(
        'income amount 1000 title salary date 15/03 category Travel',
        now: now,
        knownCategories: known,
      );

      expect(draft.type, VoiceTransactionType.income);
      expect(draft.amount, 1000);
      expect(draft.title, 'salary');
      expect(draft.date, DateTime(2026, 3, 15));
      expect(draft.category, '✈️ Travel');
    });

    test('keeps unknown category text for create prompt', () {
      final draft = VoiceTransactionParser.parse(
        'expense amount 40 title coffee date today category Cafe',
        now: now,
        knownCategories: known,
      );

      expect(draft.date, DateTime(2026, 8, 3));
      expect(draft.category, 'cafe');
      expect(
        VoiceTransactionParser.isKnownCategory(draft.category, known),
        isFalse,
      );
    });

    test('supports yesterday and no category phrase', () {
      final draft = VoiceTransactionParser.parse(
        'spent amount 12.5 title snacks date yesterday no category',
        now: now,
        knownCategories: known,
      );

      expect(draft.type, VoiceTransactionType.expense);
      expect(draft.amount, 12.5);
      expect(draft.date, DateTime(2026, 8, 2));
      expect(draft.noCategory, isTrue);
      expect(draft.hasCategory, isFalse);
    });

    test('still accepts legacy label keyword', () {
      final draft = VoiceTransactionParser.parse(
        'expense amount 10 label tea date today category Food',
        now: now,
        knownCategories: known,
      );
      expect(draft.title, 'tea');
    });

    test('parses natural speech without all keywords', () {
      final draft = VoiceTransactionParser.parse(
        'expense 200 Vada Pav today food',
        now: now,
        knownCategories: known,
      );
      expect(draft.type, VoiceTransactionType.expense);
      expect(draft.amount, 200);
      expect(draft.title, 'vada pav');
      expect(draft.date, DateTime(2026, 8, 3));
      expect(draft.category, '🍔 Food');
    });

    test('natural title does not absorb date and category leftovers', () {
      final draft = VoiceTransactionParser.parse(
        'expense 40 roti 1st August food',
        now: now,
        knownCategories: known,
      );
      expect(draft.type, VoiceTransactionType.expense);
      expect(draft.amount, 40);
      expect(draft.title, 'roti');
      expect(draft.date, DateTime(2026, 8, 1));
      expect(draft.category, '🍔 Food');
    });

    test('caps long natural titles', () {
      final draft = VoiceTransactionParser.parse(
        'expense amount 50 alpha beta gamma delta epsilon zeta today food',
        now: now,
        knownCategories: known,
      );
      expect(draft.title!.split(' ').length, lessThanOrEqualTo(4));
      expect(draft.title, isNot(contains('epsilon')));
    });

    test('merge keeps sticky fields when later chunk is partial', () {
      const first = VoiceTransactionDraft(
        type: VoiceTransactionType.expense,
        amount: 200,
        title: 'vada pav',
      );
      const second = VoiceTransactionDraft(
        date: null,
        title: null,
        noCategory: true,
      );
      final merged = first.merge(second);
      expect(merged.type, VoiceTransactionType.expense);
      expect(merged.amount, 200);
      expect(merged.title, 'vada pav');
      expect(merged.noCategory, isTrue);
    });

    test('merge does not overwrite title with date fragment or done', () {
      const first = VoiceTransactionDraft(
        type: VoiceTransactionType.expense,
        amount: 40,
        title: 'roti',
      );
      final fromDate = VoiceTransactionParser.parse(
        '1st August',
        now: now,
        knownCategories: known,
      );
      final mergedDate = first.merge(fromDate);
      expect(mergedDate.title, 'roti');
      expect(mergedDate.date, DateTime(2026, 8, 1));

      final fromDone = VoiceTransactionParser.parse('done');
      final mergedDone = mergedDate.merge(fromDone);
      expect(mergedDone.title, 'roti');
    });

    test('finish command detection', () {
      expect(VoiceTransactionParser.isFinishCommand('done'), isTrue);
      expect(VoiceTransactionParser.isFinishCommand('Done'), isTrue);
      expect(VoiceTransactionParser.isFinishCommand('zomato'), isFalse);
    });

    test('missingRequired lists type amount title', () {
      const draft = VoiceTransactionDraft(amount: 10);
      expect(draft.missingRequired, containsAll(['type', 'title']));
      expect(draft.missingRequired, isNot(contains('amount')));
    });
  });
}
