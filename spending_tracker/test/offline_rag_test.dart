import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/core/ai/offline_rag_retriever.dart';
import 'package:new_spendz/core/ai/spending_chunk.dart';
import 'package:new_spendz/core/ai/spending_knowledge_index.dart';
import 'package:new_spendz/core/ai/rule_based_coach.dart';

void main() {
  group('Offline spending RAG', () {
    final now = DateTime(2026, 7, 15);
    final expenses = [
      ExpenseItem(
        name: '🍔 Food - Delivery',
        dateTime: DateTime(2026, 7, 14),
        amount: '450',
        type: 'expense',
      ),
      ExpenseItem(
        name: '🍔 Food - Delivery',
        dateTime: DateTime(2026, 7, 12),
        amount: '380',
        type: 'expense',
      ),
      ExpenseItem(
        name: '🍔 Food - Delivery',
        dateTime: DateTime(2026, 7, 10),
        amount: '420',
        type: 'expense',
      ),
      ExpenseItem(
        name: '🚗 Travel - Cab',
        dateTime: DateTime(2026, 7, 13),
        amount: '200',
        type: 'expense',
      ),
      ExpenseItem(
        name: '💼 Work - Salary',
        dateTime: DateTime(2026, 7, 1),
        amount: '50000',
        type: 'income',
      ),
      ExpenseItem(
        name: '🍔 Food - Groceries',
        dateTime: DateTime(2026, 6, 20),
        amount: '800',
        type: 'expense',
      ),
    ];

    test('indexes habits and category summaries locally', () {
      final index = SpendingKnowledgeIndex.fromExpenses(expenses, now: now);
      expect(index.chunks, isNotEmpty);
      expect(
        index.chunks.any((c) => c.kind == SpendingChunkKind.periodSummary),
        isTrue,
      );
      expect(
        index.chunks.any((c) => c.kind == SpendingChunkKind.categorySummary),
        isTrue,
      );
      expect(
        index.chunks.any((c) => c.kind == SpendingChunkKind.habitInsight),
        isTrue,
      );
      expect(
        index.chunks.any((c) => c.text.toLowerCase().contains('food')),
        isTrue,
      );
    });

    test('retrieves food-related context for a food query', () {
      final index = SpendingKnowledgeIndex.fromExpenses(expenses, now: now);
      final retriever = OfflineRagRetriever(index.chunks);
      final hits = retriever.retrieve('Why is food spending so high?', limit: 8);
      expect(hits, isNotEmpty);
      final joined = hits.map((h) => h.text.toLowerCase()).join(' ');
      expect(joined.contains('food'), isTrue);
    });

    test('rule coach returns offline tips from retrieved context', () {
      final index = SpendingKnowledgeIndex.fromExpenses(expenses, now: now);
      final context = OfflineRagRetriever(index.chunks).retrieve(
        'How can I save this week?',
      );
      final result = RuleBasedCoach.advise(
        context: context,
        question: 'How can I save this week?',
      );
      expect(result.source, 'rules');
      expect(result.advice, contains('•'));
      expect(result.contextUsed, isNotEmpty);
    });
  });
}
