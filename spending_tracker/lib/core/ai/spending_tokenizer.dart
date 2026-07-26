/// Lightweight offline tokenizer for spending RAG (no network, no model).
abstract final class SpendingTokenizer {
  static final RegExp _word = RegExp(r"[a-z0-9]+");

  static const Set<String> _stopWords = {
    'a',
    'an',
    'the',
    'and',
    'or',
    'to',
    'of',
    'in',
    'on',
    'for',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'with',
    'by',
    'at',
    'from',
    'this',
    'that',
    'it',
    'as',
    'my',
    'me',
    'i',
    'you',
    'we',
    'our',
    'can',
    'how',
    'what',
    'when',
    'where',
    'why',
    'do',
    'does',
    'did',
    'should',
    'would',
    'could',
  };

  static List<String> tokenize(String input) {
    final lower = input.toLowerCase();
    final matches = _word.allMatches(lower);
    final tokens = <String>[];
    for (final match in matches) {
      final token = match.group(0)!;
      if (token.length < 2) continue;
      if (_stopWords.contains(token)) continue;
      tokens.add(token);
    }
    return tokens;
  }
}
