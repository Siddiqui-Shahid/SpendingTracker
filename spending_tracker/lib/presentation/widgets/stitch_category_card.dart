import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'stitch_app_card.dart';

/// Category display for insights lists or selectable category chips.
class StitchCategoryCard extends StatelessWidget {
  const StitchCategoryCard({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    this.selected = false,
    this.onTap,
    this.onSelected,
    this.percentage,
    this.amount,
    this.currencySymbol = '₹',
    this.compact = false,
  });

  final String label;
  final String? emoji;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelected;
  final double? percentage;
  final String? amount;
  final String currencySymbol;
  final bool compact;

  /// Chip-style selector for add-transaction category pickers.
  const StitchCategoryCard.chip({
    super.key,
    required this.label,
    this.emoji,
    this.icon,
    this.selected = false,
    this.onSelected,
  })  : percentage = null,
        amount = null,
        currencySymbol = '₹',
        compact = true,
        onTap = null;

  /// Full row for spending insights top categories.
  const StitchCategoryCard.insight({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    required this.percentage,
    required this.amount,
    this.currencySymbol = '₹',
    this.onTap,
  })  : selected = false,
        compact = false,
        onSelected = null;

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildChip(context);
    return _buildInsightRow(context);
  }

  Widget _buildChip(BuildContext context) {
    final colors = context.colors;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null && emoji!.isNotEmpty) Text(emoji!),
          if (emoji != null && emoji!.isNotEmpty)
            const SizedBox(width: StitchSpacing.xs),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: colors.secondaryContainer,
      backgroundColor: colors.surfaceContainerHighest,
      labelStyle: context.textTheme.labelLarge?.copyWith(
        color: selected ? colors.onSecondaryContainer : colors.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: context.stitchShapes.borderRadiusPill,
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
      child: StitchAppCard(
        padding: const EdgeInsets.all(StitchSpacing.md),
        borderRadius: context.stitchShapes.borderRadiusLg,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.45),
                borderRadius: context.stitchShapes.borderRadiusLg,
              ),
              alignment: Alignment.center,
              child: emoji != null && emoji!.isNotEmpty
                  ? Text(emoji!, style: const TextStyle(fontSize: 24))
                  : Icon(
                      icon ?? Icons.category_outlined,
                      color: colors.onPrimaryContainer,
                    ),
            ),
            const SizedBox(width: StitchSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.titleMedium),
                  if (percentage != null)
                    Text(
                      '${percentage!.toStringAsFixed(1)}% of spending',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (amount != null)
              Text(
                '$currencySymbol$amount',
                style: textTheme.titleMedium?.copyWith(
                  fontFeatures: StitchTypography.tabularFigures,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
