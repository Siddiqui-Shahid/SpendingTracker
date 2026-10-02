import '../../Model/Expense_item.dart';
import '../utils/category_utils.dart';

/// Transaction type scope for analytics filtering.
enum AnalyticsTxnType { all, expense, income }

/// Amount quick-picks used in the analytics filter sheet.
enum AnalyticsAmountPreset {
  any,
  under20,
  under50,
  under100,
  over100,
  custom,
}

/// Immutable analytics filter applied on top of the selected date period.
class AnalyticsFilter {
  const AnalyticsFilter({
    this.type = AnalyticsTxnType.all,
    this.labelQuery = '',
    this.categories = const {},
    this.amountPreset = AnalyticsAmountPreset.any,
    this.minAmount,
    this.maxAmount,
  });

  final AnalyticsTxnType type;
  final String labelQuery;
  final Set<String> categories;
  final AnalyticsAmountPreset amountPreset;
  final double? minAmount;
  final double? maxAmount;

  static const empty = AnalyticsFilter();

  bool get isActive =>
      type != AnalyticsTxnType.all ||
      labelQuery.trim().isNotEmpty ||
      categories.isNotEmpty ||
      amountPreset != AnalyticsAmountPreset.any ||
      minAmount != null ||
      maxAmount != null;

  int get activeCount {
    var count = 0;
    if (type != AnalyticsTxnType.all) count++;
    if (labelQuery.trim().isNotEmpty) count++;
    if (categories.isNotEmpty) count++;
    if (amountPreset != AnalyticsAmountPreset.any ||
        minAmount != null ||
        maxAmount != null) {
      count++;
    }
    return count;
  }

  AnalyticsFilter copyWith({
    AnalyticsTxnType? type,
    String? labelQuery,
    Set<String>? categories,
    AnalyticsAmountPreset? amountPreset,
    double? minAmount,
    double? maxAmount,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return AnalyticsFilter(
      type: type ?? this.type,
      labelQuery: labelQuery ?? this.labelQuery,
      categories: categories ?? this.categories,
      amountPreset: amountPreset ?? this.amountPreset,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  /// Returns items matching type, label, category, and amount constraints.
  List<ExpenseItem> apply(Iterable<ExpenseItem> items) {
    final query = labelQuery.trim().toLowerCase();
    final bounds = _resolvedAmountBounds();

    return items.where((item) {
      if (type == AnalyticsTxnType.expense && item.type != 'expense') {
        return false;
      }
      if (type == AnalyticsTxnType.income && item.type != 'income') {
        return false;
      }

      if (query.isNotEmpty) {
        final parsed = CategoryUtils.parseExpenseName(item.name);
        final haystack = '${parsed.title} ${item.name}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      if (categories.isNotEmpty) {
        final category = CategoryUtils.extractCategory(item.name);
        final matches = categories.any(
          (selected) =>
              selected == category ||
              selected.endsWith(' $category') ||
              CategoryUtils.parseCategoryStorage(selected).name == category,
        );
        if (!matches) return false;
      }

      final amount = double.tryParse(item.amount) ?? 0;
      if (bounds.min != null && amount < bounds.min!) return false;
      if (bounds.max != null && amount > bounds.max!) return false;

      return true;
    }).toList();
  }

  ({double? min, double? max}) _resolvedAmountBounds() {
    switch (amountPreset) {
      case AnalyticsAmountPreset.any:
        return (min: null, max: null);
      case AnalyticsAmountPreset.under20:
        return (min: null, max: 20);
      case AnalyticsAmountPreset.under50:
        return (min: null, max: 50);
      case AnalyticsAmountPreset.under100:
        return (min: null, max: 100);
      case AnalyticsAmountPreset.over100:
        return (min: 100, max: null);
      case AnalyticsAmountPreset.custom:
        return (min: minAmount, max: maxAmount);
    }
  }

  String amountSummary({String symbol = '₹'}) {
    switch (amountPreset) {
      case AnalyticsAmountPreset.any:
        return 'Any amount';
      case AnalyticsAmountPreset.under20:
        return 'Under ${symbol}20';
      case AnalyticsAmountPreset.under50:
        return 'Under ${symbol}50';
      case AnalyticsAmountPreset.under100:
        return 'Under ${symbol}100';
      case AnalyticsAmountPreset.over100:
        return 'Over ${symbol}100';
      case AnalyticsAmountPreset.custom:
        final min = minAmount;
        final max = maxAmount;
        if (min != null && max != null) {
          return '$symbol${_trim(min)} – $symbol${_trim(max)}';
        }
        if (min != null) return 'From $symbol${_trim(min)}';
        if (max != null) return 'Up to $symbol${_trim(max)}';
        return 'Custom amount';
    }
  }

  static String _trim(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}
