import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Data/Expense_data.dart';
import '../../core/ai/savings_coach_result.dart';
import '../../core/ai/savings_coach_service.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme.dart';
import 'stitch_app_card.dart';
import 'stitch_primary_button.dart';
import 'stitch_secondary_button.dart';

/// Offline RAG + on-device AI savings coach card for Insights.
class AiSavingsCoachCard extends StatefulWidget {
  const AiSavingsCoachCard({super.key});

  @override
  State<AiSavingsCoachCard> createState() => _AiSavingsCoachCardState();
}

class _AiSavingsCoachCardState extends State<AiSavingsCoachCard> {
  final _coach = SavingsCoachService();
  final _questionController = TextEditingController();

  bool _loading = false;
  bool _showContext = false;
  SavingsCoachResult? _result;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _runCoach({bool useDefault = false}) async {
    final expenses = context.read<ExpenseData>().getExpenseList();
    setState(() {
      _loading = true;
      if (useDefault) _questionController.clear();
    });

    final result = await _coach.coach(
      expenses: expenses,
      question: useDefault ? null : _questionController.text,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      _showContext = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final result = _result;

    return StitchAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: colors.primary),
              const SizedBox(width: StitchSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.aiSavingsCoach,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: StitchSpacing.sm,
                  vertical: StitchSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppStrings.aiOfflineBadge,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          Text(
            AppStrings.aiSavingsCoachSubtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: StitchSpacing.md),
          TextField(
            controller: _questionController,
            enabled: !_loading,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: AppStrings.aiCoachQuestionHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _runCoach(),
          ),
          const SizedBox(height: StitchSpacing.md),
          Row(
            children: [
              Expanded(
                child: StitchPrimaryButton(
                  label: AppStrings.aiGetPlan,
                  icon: Icons.savings_outlined,
                  isLoading: _loading,
                  expand: true,
                  onPressed: _loading ? null : () => _runCoach(useDefault: true),
                ),
              ),
              const SizedBox(width: StitchSpacing.sm),
              StitchSecondaryButton(
                label: AppStrings.aiAsk,
                onPressed: _loading ? null : () => _runCoach(),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: StitchSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(StitchSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        result.usedOnDeviceModel
                            ? Icons.phonelink_lock_rounded
                            : Icons.rule_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: StitchSpacing.sm),
                      Expanded(
                        child: Text(
                          result.usedOnDeviceModel
                              ? AppStrings.aiOnDeviceSource
                              : AppStrings.aiRulesSource,
                          style: context.textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  if (result.statusMessage != null) ...[
                    const SizedBox(height: StitchSpacing.sm),
                    Text(
                      result.statusMessage!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: StitchSpacing.md),
                  SelectableText(
                    result.advice,
                    style: context.textTheme.bodyMedium,
                  ),
                  if (result.contextUsed.isNotEmpty) ...[
                    const SizedBox(height: StitchSpacing.md),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showContext = !_showContext),
                      icon: Icon(
                        _showContext
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                      label: Text(
                        _showContext
                            ? AppStrings.aiHideContext
                            : AppStrings.aiShowContext,
                      ),
                    ),
                    if (_showContext)
                      ...result.contextUsed.map(
                        (snippet) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: StitchSpacing.sm,
                          ),
                          child: Text(
                            '• $snippet',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
