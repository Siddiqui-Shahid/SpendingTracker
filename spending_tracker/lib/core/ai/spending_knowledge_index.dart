import '../constants/app_strings.dart';
import '../utils/category_utils.dart';
import '../../Model/Expense_item.dart';
import 'spending_chunk.dart';
import 'spending_tokenizer.dart';

/// Builds a local knowledge base of spending habits from Hive transactions.
///
/// All indexing stays in-memory / on-device. Nothing is uploaded.
class SpendingKnowledgeIndex {
  SpendingKnowledgeIndex._(this.chunks, this.builtAt);

  final List<SpendingChunk> chunks;
  final DateTime builtAt;

  static const int _maxTransactionChunks = 120;

  factory SpendingKnowledgeIndex.fromExpenses(
    List<ExpenseItem> expenses, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final chunks = <SpendingChunk>[];

    final monthStart = DateTime(reference.year, reference.month, 1);
    final prevMonthStart = DateTime(reference.year, reference.month - 1, 1);
    final prevMonthEnd = monthStart.subtract(const Duration(days: 1));
    final weekStart = reference.subtract(Duration(days: reference.weekday - 1));

    final monthExpenses = <ExpenseItem>[];
    final prevMonthExpenses = <ExpenseItem>[];
    final weekExpenses = <ExpenseItem>[];
    final monthIncome = <ExpenseItem>[];

    for (final item in expenses) {
      if (item.type == 'income') {
        if (!_isBefore(item.dateTime, monthStart) &&
            !_isAfterDay(item.dateTime, reference)) {
          monthIncome.add(item);
        }
        continue;
      }
      if (item.type != 'expense') continue;

      if (!_isBefore(item.dateTime, monthStart) &&
          !_isAfterDay(item.dateTime, reference)) {
        monthExpenses.add(item);
      }
      if (!_isBefore(item.dateTime, prevMonthStart) &&
          !_isAfterDay(item.dateTime, prevMonthEnd)) {
        prevMonthExpenses.add(item);
      }
      if (!_isBefore(item.dateTime, weekStart) &&
          !_isAfterDay(item.dateTime, reference)) {
        weekExpenses.add(item);
      }
    }

    final monthSpend = _sum(monthExpenses);
    final prevSpend = _sum(prevMonthExpenses);
    final weekSpend = _sum(weekExpenses);
    final monthEarn = _sum(monthIncome);
    final leftover = monthEarn - monthSpend;

    final monthByCategory = _byCategory(monthExpenses);
    final prevByCategory = _byCategory(prevMonthExpenses);
    final weekByCategory = _byCategory(weekExpenses);

    chunks.add(
      _chunk(
        id: 'period-month',
        kind: SpendingChunkKind.periodSummary,
        text:
            'This month summary: spent ${AppStrings.currencySymbol}${monthSpend.toStringAsFixed(0)}, '
            'earned ${AppStrings.currencySymbol}${monthEarn.toStringAsFixed(0)}, '
            'leftover ${AppStrings.currencySymbol}${leftover.toStringAsFixed(0)}. '
            '${monthExpenses.length} expense transactions.',
        priority: 100,
      ),
    );

    chunks.add(
      _chunk(
        id: 'period-week',
        kind: SpendingChunkKind.periodSummary,
        text:
            'This week spending: ${AppStrings.currencySymbol}${weekSpend.toStringAsFixed(0)} '
            'across ${weekExpenses.length} expenses.',
        priority: 95,
      ),
    );

    if (prevSpend > 0) {
      final deltaPct = ((monthSpend - prevSpend) / prevSpend) * 100;
      final direction = deltaPct >= 0 ? 'up' : 'down';
      chunks.add(
        _chunk(
          id: 'habit-mom',
          kind: SpendingChunkKind.habitInsight,
          text:
              'Month-over-month habit: spending is $direction ${deltaPct.abs().toStringAsFixed(0)}% '
              'vs last month (now ${AppStrings.currencySymbol}${monthSpend.toStringAsFixed(0)}, '
              'was ${AppStrings.currencySymbol}${prevSpend.toStringAsFixed(0)}).',
          priority: 90,
        ),
      );
    }

    final sortedCats = monthByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var i = 0; i < sortedCats.length && i < 8; i++) {
      final entry = sortedCats[i];
      final share = monthSpend > 0 ? (entry.value / monthSpend) * 100 : 0.0;
      final prev = prevByCategory[entry.key] ?? 0;
      var trend = '';
      if (prev > 0) {
        final catDelta = ((entry.value - prev) / prev) * 100;
        trend = catDelta >= 0
            ? ' Up ${catDelta.toStringAsFixed(0)}% vs last month.'
            : ' Down ${catDelta.abs().toStringAsFixed(0)}% vs last month.';
      }
      chunks.add(
        _chunk(
          id: 'cat-${entry.key}',
          kind: SpendingChunkKind.categorySummary,
          text:
              'Category ${entry.key}: ${AppStrings.currencySymbol}${entry.value.toStringAsFixed(0)} '
              'this month (${share.toStringAsFixed(0)}% of spend).$trend',
          category: entry.key,
          amount: entry.value,
          priority: 80 - i,
        ),
      );
    }

    // Recurring / frequent merchant-like titles.
    final titleCounts = <String, int>{};
    final titleSpend = <String, double>{};
    for (final item in monthExpenses) {
      final parsed = CategoryUtils.parseExpenseName(item.name);
      final title = parsed.title.trim().toLowerCase();
      if (title.isEmpty) continue;
      titleCounts[title] = (titleCounts[title] ?? 0) + 1;
      titleSpend[title] =
          (titleSpend[title] ?? 0) + (double.tryParse(item.amount) ?? 0);
    }
    final repeats = titleCounts.entries.where((e) => e.value >= 3).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (var i = 0; i < repeats.length && i < 5; i++) {
      final title = repeats[i].key;
      chunks.add(
        _chunk(
          id: 'habit-repeat-$i',
          kind: SpendingChunkKind.habitInsight,
          text:
              'Repeated habit: "$title" logged ${repeats[i].value} times this month '
              'for ${AppStrings.currencySymbol}${(titleSpend[title] ?? 0).toStringAsFixed(0)}. '
              'Cutting frequency could increase savings.',
          priority: 70 - i,
        ),
      );
    }

    if (weekByCategory.isNotEmpty) {
      final topWeek = weekByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = topWeek.first;
      chunks.add(
        _chunk(
          id: 'habit-week-focus',
          kind: SpendingChunkKind.habitInsight,
          text:
              'This week focus leak: ${top.key} at '
              '${AppStrings.currencySymbol}${top.value.toStringAsFixed(0)}. '
              'Reducing this category is the fastest save lever right now.',
          category: top.key,
          amount: top.value,
          priority: 85,
        ),
      );
    }

    // Recent transaction evidence (newest first, capped).
    final recent = expenses.where((e) => e.type == 'expense').toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    for (var i = 0; i < recent.length && i < _maxTransactionChunks; i++) {
      final item = recent[i];
      final parsed = CategoryUtils.parseExpenseName(item.name);
      final category = parsed.category ?? 'Other';
      final title = parsed.title;
      final amount = double.tryParse(item.amount) ?? 0;
      final date =
          '${item.dateTime.year}-${item.dateTime.month.toString().padLeft(2, '0')}-${item.dateTime.day.toString().padLeft(2, '0')}';
      chunks.add(
        _chunk(
          id: 'txn-$i-${item.dateTime.millisecondsSinceEpoch}',
          kind: SpendingChunkKind.transaction,
          text:
              'Transaction $date: expense $category "$title" '
              '${AppStrings.currencySymbol}${amount.toStringAsFixed(0)}.',
          category: category,
          date: item.dateTime,
          amount: amount,
          priority: 10,
        ),
      );
    }

    return SpendingKnowledgeIndex._(chunks, reference);
  }

  static SpendingChunk _chunk({
    required String id,
    required SpendingChunkKind kind,
    required String text,
    String? category,
    DateTime? date,
    double? amount,
    int priority = 0,
  }) {
    return SpendingChunk(
      id: id,
      kind: kind,
      text: text,
      tokens: SpendingTokenizer.tokenize(text),
      category: category,
      date: date,
      amount: amount,
      priority: priority,
    );
  }

  static double _sum(List<ExpenseItem> items) {
    var total = 0.0;
    for (final item in items) {
      total += double.tryParse(item.amount) ?? 0;
    }
    return total;
  }

  static Map<String, double> _byCategory(List<ExpenseItem> items) {
    final map = <String, double>{};
    for (final item in items) {
      final category = CategoryUtils.extractCategory(item.name);
      map[category] = (map[category] ?? 0) + (double.tryParse(item.amount) ?? 0);
    }
    return map;
  }

  static bool _isBefore(DateTime value, DateTime start) {
    final day = DateTime(value.year, value.month, value.day);
    final edge = DateTime(start.year, start.month, start.day);
    return day.isBefore(edge);
  }

  static bool _isAfterDay(DateTime value, DateTime end) {
    final day = DateTime(value.year, value.month, value.day);
    final edge = DateTime(end.year, end.month, end.day);
    return day.isAfter(edge);
  }
}
