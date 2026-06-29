import 'package:flutter/material.dart';
import 'stitch_colors.dart';

/// Domain-specific semantic colors for spending UI.
@immutable
class StitchSemanticColors extends ThemeExtension<StitchSemanticColors> {
  const StitchSemanticColors({
    required this.income,
    required this.onIncome,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.onExpense,
    required this.expenseContainer,
    required this.onExpenseContainer,
    required this.cardBorder,
    required this.subtleDivider,
  });

  final Color income;
  final Color onIncome;
  final Color incomeContainer;
  final Color onIncomeContainer;
  final Color expense;
  final Color onExpense;
  final Color expenseContainer;
  final Color onExpenseContainer;
  final Color cardBorder;
  final Color subtleDivider;

  factory StitchSemanticColors.from(ColorScheme colors) {
    final isDark = colors.brightness == Brightness.dark;
    return StitchSemanticColors(
      income: colors.tertiary,
      onIncome: colors.onTertiary,
      incomeContainer: colors.tertiaryContainer,
      onIncomeContainer: colors.onTertiaryContainer,
      expense: colors.error,
      onExpense: colors.onError,
      expenseContainer: colors.errorContainer,
      onExpenseContainer: colors.onErrorContainer,
      cardBorder: colors.outlineVariant,
      subtleDivider: isDark
          ? StitchColors.darkOutlineVariant.withValues(alpha: 0.6)
          : StitchColors.lightOutlineVariant.withValues(alpha: 0.8),
    );
  }

  static const StitchSemanticColors dark = StitchSemanticColors(
    income: StitchColors.darkTertiary,
    onIncome: StitchColors.darkOnTertiary,
    incomeContainer: StitchColors.darkTertiaryContainer,
    onIncomeContainer: StitchColors.darkOnTertiaryContainer,
    expense: StitchColors.darkError,
    onExpense: StitchColors.darkOnError,
    expenseContainer: StitchColors.darkErrorContainer,
    onExpenseContainer: StitchColors.darkOnErrorContainer,
    cardBorder: StitchColors.darkOutlineVariant,
    subtleDivider: StitchColors.darkOutlineVariant,
  );

  static const StitchSemanticColors light = StitchSemanticColors(
    income: StitchColors.lightTertiary,
    onIncome: StitchColors.lightOnTertiary,
    incomeContainer: StitchColors.lightTertiaryContainer,
    onIncomeContainer: StitchColors.lightOnTertiaryContainer,
    expense: StitchColors.lightError,
    onExpense: StitchColors.lightOnError,
    expenseContainer: StitchColors.lightErrorContainer,
    onExpenseContainer: StitchColors.lightOnErrorContainer,
    cardBorder: StitchColors.lightOutlineVariant,
    subtleDivider: StitchColors.lightOutlineVariant,
  );

  @override
  StitchSemanticColors copyWith({
    Color? income,
    Color? onIncome,
    Color? incomeContainer,
    Color? onIncomeContainer,
    Color? expense,
    Color? onExpense,
    Color? expenseContainer,
    Color? onExpenseContainer,
    Color? cardBorder,
    Color? subtleDivider,
  }) {
    return StitchSemanticColors(
      income: income ?? this.income,
      onIncome: onIncome ?? this.onIncome,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      onIncomeContainer: onIncomeContainer ?? this.onIncomeContainer,
      expense: expense ?? this.expense,
      onExpense: onExpense ?? this.onExpense,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      onExpenseContainer: onExpenseContainer ?? this.onExpenseContainer,
      cardBorder: cardBorder ?? this.cardBorder,
      subtleDivider: subtleDivider ?? this.subtleDivider,
    );
  }

  @override
  StitchSemanticColors lerp(
    ThemeExtension<StitchSemanticColors>? other,
    double t,
  ) {
    if (other is! StitchSemanticColors) return this;
    return StitchSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      onIncome: Color.lerp(onIncome, other.onIncome, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      onIncomeContainer:
          Color.lerp(onIncomeContainer, other.onIncomeContainer, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      onExpense: Color.lerp(onExpense, other.onExpense, t)!,
      expenseContainer: Color.lerp(expenseContainer, other.expenseContainer, t)!,
      onExpenseContainer:
          Color.lerp(onExpenseContainer, other.onExpenseContainer, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      subtleDivider: Color.lerp(subtleDivider, other.subtleDivider, t)!,
    );
  }
}
