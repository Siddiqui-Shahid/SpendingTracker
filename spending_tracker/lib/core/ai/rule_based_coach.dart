import 'spending_chunk.dart';
import 'savings_coach_result.dart';

/// Deterministic offline coach when on-device LLM is unavailable.
abstract final class RuleBasedCoach {
  static SavingsCoachResult advise({
    required List<SpendingChunk> context,
    required String question,
  }) {
    final habits = context
        .where((c) => c.kind == SpendingChunkKind.habitInsight)
        .map((c) => c.text)
        .toList();
    final categories = context
        .where((c) => c.kind == SpendingChunkKind.categorySummary)
        .toList();
    final periods = context
        .where((c) => c.kind == SpendingChunkKind.periodSummary)
        .map((c) => c.text)
        .toList();

    final bullets = <String>[];

    if (periods.isNotEmpty) {
      bullets.add(periods.first);
    }

    if (habits.isNotEmpty) {
      bullets.add(habits.first);
    }

    if (categories.isNotEmpty) {
      final top = categories.first;
      final name = top.category ?? 'top category';
      bullets.add(
        'Focus save lever: trim $name this week. '
        'Skip 2–3 discretionary purchases there and re-check leftover.',
      );
    } else {
      bullets.add(
        'Log every expense for 7 days, then cut the largest discretionary category by 15%.',
      );
    }

    if (habits.length > 1) {
      bullets.add(habits[1]);
    } else {
      bullets.add(
        'Move a fixed weekly amount to savings on payday before discretionary spending.',
      );
    }

    final advice = bullets.take(4).map((b) => '• $b').join('\n');
    return SavingsCoachResult(
      advice: advice,
      source: 'rules',
      contextUsed: context.map((c) => c.text).toList(),
      question: question,
      statusMessage:
          'On-device AI is unavailable on this device. Showing private rule-based tips from your local spending data.',
    );
  }
}
