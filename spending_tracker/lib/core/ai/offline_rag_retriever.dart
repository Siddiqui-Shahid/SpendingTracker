import 'dart:math' as math;

import 'spending_chunk.dart';
import 'spending_tokenizer.dart';

/// Offline BM25 retriever over spending chunks (local RAG, no embeddings API).
class OfflineRagRetriever {
  OfflineRagRetriever(this.chunks, {this.k1 = 1.2, this.b = 0.75}) {
    _avgDl = chunks.isEmpty
        ? 0
        : chunks.map((c) => c.tokens.length).reduce((a, b) => a + b) /
            chunks.length;
    _docFreq = <String, int>{};
    for (final chunk in chunks) {
      for (final token in chunk.tokens.toSet()) {
        _docFreq[token] = (_docFreq[token] ?? 0) + 1;
      }
    }
  }

  final List<SpendingChunk> chunks;
  final double k1;
  final double b;

  late final double _avgDl;
  late final Map<String, int> _docFreq;

  /// Returns top-[limit] chunks relevant to [query], always pinning habit/period.
  List<SpendingChunk> retrieve(String query, {int limit = 8}) {
    if (chunks.isEmpty) return const [];

    final queryTokens = SpendingTokenizer.tokenize(query);
    final scored = <({SpendingChunk chunk, double score})>[];

    for (final chunk in chunks) {
      var score = _bm25(queryTokens, chunk);
      // Prefer habit / period / category summaries in coaching prompts.
      if (chunk.kind == SpendingChunkKind.habitInsight) score += 1.5;
      if (chunk.kind == SpendingChunkKind.periodSummary) score += 1.2;
      if (chunk.kind == SpendingChunkKind.categorySummary) score += 0.8;
      score += chunk.priority / 100.0;
      scored.add((chunk: chunk, score: score));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.chunk.priority.compareTo(a.chunk.priority);
    });

    final selected = <SpendingChunk>[];
    final seen = <String>{};

    void addChunk(SpendingChunk chunk) {
      if (seen.add(chunk.id)) selected.add(chunk);
    }

    // Pin high-signal habit/period context so the model always knows habits.
    for (final chunk in chunks) {
      if (chunk.kind == SpendingChunkKind.periodSummary ||
          chunk.kind == SpendingChunkKind.habitInsight) {
        addChunk(chunk);
      }
      if (selected.length >= 4) break;
    }

    for (final entry in scored) {
      if (selected.length >= limit) break;
      if (entry.score <= 0 && entry.chunk.kind == SpendingChunkKind.transaction) {
        continue;
      }
      addChunk(entry.chunk);
    }

    // If query matched nothing useful, still return top summaries + recent txns.
    if (selected.length < limit) {
      for (final entry in scored) {
        if (selected.length >= limit) break;
        addChunk(entry.chunk);
      }
    }

    return selected.take(limit).toList();
  }

  double _bm25(List<String> queryTokens, SpendingChunk chunk) {
    if (queryTokens.isEmpty || chunk.tokens.isEmpty || _avgDl == 0) return 0;
    final tfMap = <String, int>{};
    for (final token in chunk.tokens) {
      tfMap[token] = (tfMap[token] ?? 0) + 1;
    }

    final n = chunks.length;
    final dl = chunk.tokens.length.toDouble();
    var score = 0.0;

    for (final term in queryTokens.toSet()) {
      final tf = tfMap[term] ?? 0;
      if (tf == 0) continue;
      final df = _docFreq[term] ?? 0;
      final idf = math.log(1 + (n - df + 0.5) / (df + 0.5));
      final denom = tf + k1 * (1 - b + b * (dl / _avgDl));
      score += idf * ((tf * (k1 + 1)) / denom);
    }
    return score;
  }
}
