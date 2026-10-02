import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/analytics/analytics_filter.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/category_utils.dart';
import 'stitch_primary_button.dart';
import 'stitch_secondary_button.dart';

/// Bottom sheet for Insights filters: type, amount, label, categories.
class AnalyticsFilterSheet extends StatefulWidget {
  const AnalyticsFilterSheet({
    super.key,
    required this.initial,
    required this.availableCategories,
  });

  final AnalyticsFilter initial;
  final List<String> availableCategories;

  static Future<AnalyticsFilter?> show(
    BuildContext context, {
    required AnalyticsFilter initial,
    required List<String> availableCategories,
  }) {
    return showModalBottomSheet<AnalyticsFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AnalyticsFilterSheet(
        initial: initial,
        availableCategories: availableCategories,
      ),
    );
  }

  @override
  State<AnalyticsFilterSheet> createState() => _AnalyticsFilterSheetState();
}

class _AnalyticsFilterSheetState extends State<AnalyticsFilterSheet> {
  late AnalyticsTxnType _type;
  late TextEditingController _labelController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late Set<String> _categories;
  late AnalyticsAmountPreset _amountPreset;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial.type;
    _labelController = TextEditingController(text: initial.labelQuery);
    _categories = Set<String>.from(initial.categories);
    _amountPreset = initial.amountPreset;
    _minController = TextEditingController(
      text: initial.minAmount?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: initial.maxAmount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  AnalyticsFilter _buildFilter() {
    double? min;
    double? max;
    if (_amountPreset == AnalyticsAmountPreset.custom) {
      min = double.tryParse(_minController.text.trim());
      max = double.tryParse(_maxController.text.trim());
    }
    return AnalyticsFilter(
      type: _type,
      labelQuery: _labelController.text.trim(),
      categories: Set<String>.from(_categories),
      amountPreset: _amountPreset,
      minAmount: min,
      maxAmount: max,
    );
  }

  void _clearAll() {
    setState(() {
      _type = AnalyticsTxnType.all;
      _labelController.clear();
      _categories.clear();
      _amountPreset = AnalyticsAmountPreset.any;
      _minController.clear();
      _maxController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final symbol = AppStrings.currencySymbol;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  StitchSpacing.lg,
                  StitchSpacing.sm,
                  StitchSpacing.lg,
                  StitchSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter insights',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StitchSpacing.lg,
                  ),
                  children: [
                    Text('Type', style: textTheme.titleSmall),
                    const SizedBox(height: StitchSpacing.sm),
                    SegmentedButton<AnalyticsTxnType>(
                      segments: const [
                        ButtonSegment(
                          value: AnalyticsTxnType.all,
                          label: Text('All'),
                          icon: Icon(Icons.all_inclusive_rounded),
                        ),
                        ButtonSegment(
                          value: AnalyticsTxnType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment(
                          value: AnalyticsTxnType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (selection) {
                        setState(() => _type = selection.first);
                      },
                    ),
                    const SizedBox(height: StitchSpacing.lg),
                    Text('Label', style: textTheme.titleSmall),
                    const SizedBox(height: StitchSpacing.sm),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'Search by title / label',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: StitchSpacing.lg),
                    Text('Amount', style: textTheme.titleSmall),
                    const SizedBox(height: StitchSpacing.sm),
                    Wrap(
                      spacing: StitchSpacing.sm,
                      runSpacing: StitchSpacing.sm,
                      children: [
                        for (final preset in AnalyticsAmountPreset.values)
                          FilterChip(
                            label: Text(_presetLabel(preset, symbol)),
                            selected: _amountPreset == preset,
                            showCheckmark: false,
                            onSelected: (_) {
                              setState(() => _amountPreset = preset);
                            },
                          ),
                      ],
                    ),
                    if (_amountPreset == AnalyticsAmountPreset.custom) ...[
                      const SizedBox(height: StitchSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minController,
                              decoration: InputDecoration(
                                labelText: 'Min ($symbol)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: StitchSpacing.md),
                          Expanded(
                            child: TextField(
                              controller: _maxController,
                              decoration: InputDecoration(
                                labelText: 'Max ($symbol)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.]'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: StitchSpacing.lg),
                    Text(
                      'Categories',
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: StitchSpacing.xs),
                    Text(
                      'Select one or many. Leave empty for all.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: StitchSpacing.sm),
                    if (widget.availableCategories.isEmpty)
                      Text(
                        'No categories yet.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    else
                      Wrap(
                        spacing: StitchSpacing.sm,
                        runSpacing: StitchSpacing.sm,
                        children: [
                          for (final stored in widget.availableCategories)
                            Builder(
                              builder: (context) {
                                final parsed =
                                    CategoryUtils.parseCategoryStorage(stored);
                                final selected = _categories.contains(stored) ||
                                    _categories.contains(parsed.name);
                                return FilterChip(
                                  avatar: parsed.emoji != null
                                      ? Text(parsed.emoji!)
                                      : null,
                                  label: Text(parsed.name),
                                  selected: selected,
                                  onSelected: (value) {
                                    setState(() {
                                      if (value) {
                                        _categories
                                          ..remove(parsed.name)
                                          ..add(stored);
                                      } else {
                                        _categories
                                          ..remove(stored)
                                          ..remove(parsed.name);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: StitchSpacing.xl),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  StitchSpacing.lg,
                  StitchSpacing.sm,
                  StitchSpacing.lg,
                  StitchSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: StitchSecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: StitchSpacing.md),
                    Expanded(
                      child: StitchPrimaryButton(
                        label: 'Apply',
                        onPressed: () =>
                            Navigator.of(context).pop(_buildFilter()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _presetLabel(AnalyticsAmountPreset preset, String symbol) {
    return switch (preset) {
      AnalyticsAmountPreset.any => 'Any',
      AnalyticsAmountPreset.under20 => 'Under ${symbol}20',
      AnalyticsAmountPreset.under50 => 'Under ${symbol}50',
      AnalyticsAmountPreset.under100 => 'Under ${symbol}100',
      AnalyticsAmountPreset.over100 => 'Over ${symbol}100',
      AnalyticsAmountPreset.custom => 'Custom',
    };
  }
}

/// Compact chip row summarizing active analytics filters.
class AnalyticsActiveFilterBar extends StatelessWidget {
  const AnalyticsActiveFilterBar({
    super.key,
    required this.filter,
    required this.onClear,
    required this.onEdit,
  });

  final AnalyticsFilter filter;
  final VoidCallback onClear;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (!filter.isActive) return const SizedBox.shrink();

    final colors = context.colors;
    final chips = <Widget>[];

    if (filter.type != AnalyticsTxnType.all) {
      chips.add(
        _chip(
          context,
          filter.type == AnalyticsTxnType.expense ? 'Expense' : 'Income',
        ),
      );
    }
    if (filter.labelQuery.trim().isNotEmpty) {
      chips.add(_chip(context, '“${filter.labelQuery.trim()}”'));
    }
    if (filter.amountPreset != AnalyticsAmountPreset.any ||
        filter.minAmount != null ||
        filter.maxAmount != null) {
      chips.add(_chip(context, filter.amountSummary()));
    }
    if (filter.categories.isNotEmpty) {
      final names = filter.categories
          .map((c) => CategoryUtils.parseCategoryStorage(c).name)
          .take(3)
          .join(', ');
      final more = filter.categories.length > 3
          ? ' +${filter.categories.length - 3}'
          : '';
      chips.add(_chip(context, '$names$more'));
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.stitchSpacing.gutter,
        StitchSpacing.xs,
        context.stitchSpacing.gutter,
        StitchSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final chip in chips) ...[
                    chip,
                    const SizedBox(width: StitchSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit filters',
            onPressed: onEdit,
            icon: Icon(Icons.tune_rounded, color: colors.primary),
          ),
          IconButton(
            tooltip: 'Clear filters',
            onPressed: onClear,
            icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: context.colors.outlineVariant),
      backgroundColor: context.colors.secondaryContainer.withValues(alpha: 0.55),
    );
  }
}
