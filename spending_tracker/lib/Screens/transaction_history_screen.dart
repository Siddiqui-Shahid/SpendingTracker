import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/Expense_data.dart';
import '../Model/Expense_item.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/category_utils.dart';
import '../presentation/widgets/widgets.dart';
import 'addTransactionPage.dart';

/// Full transaction history with search, month filter, and date grouping.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isEditMode = false;
  late DateTime _selectedMonth = DateTime.now();
  late List<DateTime> _availableMonths = [DateTime.now()];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _expenseListVersion = -1;

  void _maybeSyncMonths(List<ExpenseItem> allItems) {
    final version = allItems.length;
    if (version == _expenseListVersion) return;
    _expenseListVersion = version;

    if (allItems.isEmpty) {
      _availableMonths = [DateTime.now()];
      _selectedMonth = DateTime.now();
      return;
    }

    DateTime earliest = allItems.first.dateTime;
    DateTime latest = allItems.first.dateTime;

    for (final expense in allItems) {
      if (expense.dateTime.isBefore(earliest)) earliest = expense.dateTime;
      if (expense.dateTime.isAfter(latest)) latest = expense.dateTime;
    }

    final months = <DateTime>[];
    var current = DateTime(earliest.year, earliest.month, 1);
    final lastDay = DateTime(latest.year, latest.month + 1, 0);

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    _availableMonths = months;
    final today = DateTime.now();
    _selectedMonth = months.reduce((a, b) {
      final aDiff =
          (a.year - today.year).abs() * 12 + (a.month - today.month).abs();
      final bDiff =
          (b.year - today.year).abs() * 12 + (b.month - today.month).abs();
      return aDiff < bDiff ? a : b;
    });
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<ExpenseItem> _filterExpenses(List<ExpenseItem> all) {
    return all.where((expense) {
      final inMonth = expense.dateTime.year == _selectedMonth.year &&
          expense.dateTime.month == _selectedMonth.month;
      if (!inMonth) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return expense.name.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Map<String, List<ExpenseItem>> _groupByDate(List<ExpenseItem> items) {
    final groups = <String, List<ExpenseItem>>{};
    for (final item in items) {
      final label = CategoryUtils.dateSectionLabel(item.dateTime);
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, _) {
        final allItems = List<ExpenseItem>.from(
          value.getExpenseList().whereType<ExpenseItem>(),
        );
        _maybeSyncMonths(allItems);
        final filtered = _filterExpenses(allItems);
        final grouped = _groupByDate(filtered);

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.transactionHistory),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  filtered.isEmpty
                      ? Icons.edit_outlined
                      : (_isEditMode ? Icons.close : Icons.edit_outlined),
                ),
                tooltip: _isEditMode ? 'Done' : 'Edit',
                onPressed: filtered.isEmpty
                    ? null
                    : () => setState(() => _isEditMode = !_isEditMode),
              ),
            ],
          ),
          body: Column(
            children: [
              StitchSearchField(
                controller: _searchController,
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
              _MonthSelector(
                label: _formatMonth(_selectedMonth),
                canGoPrevious: _availableMonths.indexOf(_selectedMonth) > 0,
                canGoNext: _availableMonths.indexOf(_selectedMonth) <
                    _availableMonths.length - 1,
                onPrevious: () {
                  final idx = _availableMonths.indexOf(_selectedMonth);
                  if (idx > 0) {
                    setState(() => _selectedMonth = _availableMonths[idx - 1]);
                  }
                },
                onNext: () {
                  final idx = _availableMonths.indexOf(_selectedMonth);
                  if (idx < _availableMonths.length - 1) {
                    setState(() => _selectedMonth = _availableMonths[idx + 1]);
                  }
                },
              ),
              Expanded(
                child: filtered.isEmpty
                    ? StitchEmptyState(
                        message: _searchQuery.isEmpty
                            ? 'No transactions in ${_formatMonth(_selectedMonth)}'
                            : 'No results for "$_searchQuery"',
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom + 96,
                        ),
                        itemCount: grouped.length,
                        itemBuilder: (context, sectionIndex) {
                          final sectionKey = grouped.keys.elementAt(sectionIndex);
                          final sectionItems = grouped[sectionKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StitchDateSectionHeader(label: sectionKey),
                              ...sectionItems.map((item) {
                                final parsed =
                                    CategoryUtils.parseExpenseName(item.name);
                                return StitchTransactionTile(
                                  title: parsed.title,
                                  subtitle: CategoryUtils.formatTransactionSubtitle(
                                    item.dateTime,
                                  ),
                                  category: parsed.category,
                                  emoji: parsed.emoji,
                                  amount: item.amount,
                                  isIncome: item.type == 'income',
                                  isEditMode: _isEditMode,
                                  onTap: () async {
                                    setState(() => _isEditMode = false);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionPage(
                                          initialItem: item,
                                          itemIndex: value
                                              .getExpenseList()
                                              .indexOf(item),
                                          isEdit: true,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    Provider.of<ExpenseData>(
                                      context,
                                      listen: false,
                                    ).deleteExpense(item);
                                    setState(() {});
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.stitchSpacing.gutter),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: canGoPrevious ? colors.primary : colors.outlineVariant,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: StitchSpacing.sm,
                horizontal: StitchSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: context.stitchShapes.borderRadiusMd,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Center(
                child: Text(
                  label,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: canGoNext ? colors.primary : colors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
