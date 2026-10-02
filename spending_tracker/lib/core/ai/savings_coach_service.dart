import 'package:flutter/foundation.dart';
import 'package:flutter_native_ai/flutter_native_ai.dart';

import '../../Model/Expense_item.dart';
import 'offline_rag_retriever.dart';
import 'rule_based_coach.dart';
import 'savings_coach_result.dart';
import 'spending_chunk.dart';
import 'spending_knowledge_index.dart';

/// Fully offline savings coach: local RAG + on-device LLM (Apple / Gemini Nano).
///
/// - Builds a spending knowledge index from Hive transactions
/// - Retrieves relevant habit/category/transaction chunks (BM25)
/// - Generates advice with Apple Foundation Models (iOS) or Gemini Nano (Android)
/// - Falls back to rule-based tips when the model is unavailable
///
/// No cloud API keys. No developer inference cost. Data never leaves the device
/// for the RAG path; generation uses OS on-device models when present.
class SavingsCoachService {
  SavingsCoachService({OnDeviceAi? ai}) : _ai = ai ?? OnDeviceAi();

  final OnDeviceAi _ai;

  static const String defaultQuestion =
      'Based on my spending habits, how can I save more money this week? '
      'Give 3 concrete actions.';

  static const String _instructions =
      'You are MoneySeer, a private on-device savings coach. '
      'Use ONLY the provided spending context. Do not invent transactions. '
      'Be concise: 3 short actionable bullets. No fluff, no markdown tables. '
      'Speak directly to the user. Prefer cutting the biggest discretionary leak.';

  /// Returns whether the OS on-device model can generate now.
  Future<OnDeviceAiStatus> status() => _ai.status();

  /// Optionally prepare/download the on-device model (Android AICore).
  Future<OnDeviceAiStatus> ensureReady() => _ai.ensureReady();

  Future<SavingsCoachResult> coach({
    required List<ExpenseItem> expenses,
    String? question,
  }) async {
    final ask = (question == null || question.trim().isEmpty)
        ? defaultQuestion
        : question.trim();

    final index = SpendingKnowledgeIndex.fromExpenses(expenses);
    if (index.chunks.isEmpty) {
      return const SavingsCoachResult(
        advice:
            '• Add a few income and expense entries first.\n'
            '• Once you have a week of data, I can spot habits and save levers.',
        source: 'rules',
        contextUsed: [],
        statusMessage: 'Not enough local spending data yet.',
      );
    }

    final retriever = OfflineRagRetriever(index.chunks);
    final context = retriever.retrieve(ask, limit: 10);
    final prompt = _buildRagPrompt(question: ask, context: context);

    try {
      final status = await _ai.status();
      if (!status.isAvailable) {
        if (status.canInitialize) {
          final ready = await _ai.ensureReady();
          if (!ready.isAvailable) {
            return RuleBasedCoach.advise(context: context, question: ask)
                .copyWithStatus(
              'On-device model not ready (${ready.reason ?? 'unavailable'}). '
              'Using private rule-based tips from your local data.',
            );
          }
        } else {
          return RuleBasedCoach.advise(context: context, question: ask);
        }
      }

      final session = await _ai.createSession(
        instructions: _instructions,
        initializationPolicy: OnDeviceAiInitializationPolicy.whenNeeded,
      );
      try {
        final result = await session.generateText(
          prompt: prompt,
          config: const OnDeviceAiGenerationConfig(
            maxTokens: 220,
            temperature: 0.3,
          ),
        );
        final text = result.text.trim();
        if (text.isEmpty) {
          return RuleBasedCoach.advise(context: context, question: ask);
        }
        return SavingsCoachResult(
          advice: text,
          source: 'onDevice',
          contextUsed: context.map((c) => c.text).toList(),
          question: ask,
          statusMessage: _platformReadyMessage(),
        );
      } finally {
        await session.dispose();
      }
    } catch (error, stack) {
      debugPrint('SavingsCoachService on-device failure: $error\n$stack');
      return RuleBasedCoach.advise(context: context, question: ask).copyWithStatus(
        'On-device AI failed locally. Showing private rule-based tips instead.',
      );
    }
  }

  String _buildRagPrompt({
    required String question,
    required List<SpendingChunk> context,
  }) {
    final buffer = StringBuffer()
      ..writeln('SPENDING CONTEXT (retrieved from on-device RAG):');
    for (var i = 0; i < context.length; i++) {
      buffer.writeln('${i + 1}. ${context[i].text}');
    }
    buffer
      ..writeln()
      ..writeln('USER QUESTION:')
      ..writeln(question)
      ..writeln()
      ..writeln(
        'Answer with exactly 3 short bullets grounded in the context above.',
      );
    return buffer.toString();
  }

  String _platformReadyMessage() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'Generated on-device with Apple Intelligence. Your data stayed on this device.';
      case TargetPlatform.android:
        return 'Generated on-device with Gemini Nano. Your data stayed on this device.';
      default:
        return 'Generated with on-device AI. Your data stayed on this device.';
    }
  }
}

extension on SavingsCoachResult {
  SavingsCoachResult copyWithStatus(String message) {
    return SavingsCoachResult(
      advice: advice,
      source: source,
      contextUsed: contextUsed,
      question: question,
      statusMessage: message,
    );
  }
}
