/// A retrieval unit for offline spending RAG.
enum SpendingChunkKind {
  transaction,
  categorySummary,
  habitInsight,
  periodSummary,
}

/// Text chunk indexed for local retrieval (never leaves the device).
class SpendingChunk {
  const SpendingChunk({
    required this.id,
    required this.kind,
    required this.text,
    required this.tokens,
    this.category,
    this.date,
    this.amount,
    this.priority = 0,
  });

  final String id;
  final SpendingChunkKind kind;
  final String text;
  final List<String> tokens;
  final String? category;
  final DateTime? date;
  final double? amount;

  /// Higher priority chunks are preferred when scores tie (habit/period first).
  final int priority;
}
