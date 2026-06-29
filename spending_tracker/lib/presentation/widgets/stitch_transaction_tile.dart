import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';

/// Transaction row used on the home and history screens (72dp Stitch spec).
class StitchTransactionTile extends StatelessWidget {
  const StitchTransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncome,
    this.subtitle,
    this.category,
    this.emoji,
    this.categoryIcon,
    this.isEditMode = false,
    this.onTap,
    this.onDelete,
    this.currencySymbol = AppStrings.currencySymbol,
  });

  final String title;
  final String amount;
  final bool isIncome;
  final String? subtitle;
  final String? category;
  final String? emoji;
  final IconData? categoryIcon;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.stitchSemantics;
    final textTheme = context.textTheme;
    final amountColor = isIncome ? semantics.income : semantics.expense;
    final tileHeight = context.stitchSpacing.transactionListItemHeight;

    return Semantics(
      button: onTap != null,
      label: '$title, ${isIncome ? 'income' : 'expense'} '
          '${CurrencyFormatter.format(double.tryParse(amount) ?? 0, symbol: currencySymbol)}',
      child: SizedBox(
        height: tileHeight,
        child: ListTile(
          onTap: onTap,
          contentPadding: StitchSpacing.listItemPadding,
          minTileHeight: tileHeight,
          leading: _buildLeading(context),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: _buildSubtitle(context),
          trailing: isEditMode
              ? IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                  tooltip: 'Delete transaction',
                  onPressed: onDelete,
                )
              : Text(
                  CurrencyFormatter.format(
                    double.tryParse(amount) ?? 0,
                    symbol: currencySymbol,
                  ),
                  style: CurrencyFormatter.amountStyle(
                    textTheme.titleMedium,
                    color: amountColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    final lines = <String>[];

    if (subtitle != null && subtitle!.isNotEmpty) {
      lines.add(subtitle!);
    }
    if (category != null && category!.isNotEmpty) {
      lines.add(category!);
    }

    if (lines.isEmpty) return null;

    return Text(
      lines.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (emoji != null && emoji!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: context.colors.primaryContainer,
        child: Text(emoji!, style: const TextStyle(fontSize: 22)),
      );
    }

    if (categoryIcon != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: context.colors.primaryContainer,
        child: Icon(
          categoryIcon,
          size: 20,
          color: context.colors.onPrimaryContainer,
        ),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: context.colors.surfaceContainerHigh,
      child: Icon(
        Icons.receipt_long_rounded,
        size: 20,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}
