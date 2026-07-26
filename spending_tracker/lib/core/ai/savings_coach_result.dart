/// Result of a fully offline savings coaching turn.
class SavingsCoachResult {
  const SavingsCoachResult({
    required this.advice,
    required this.source,
    required this.contextUsed,
    this.statusMessage,
    this.question,
  });

  final String advice;

  /// `onDevice` | `rules`
  final String source;

  /// Retrieved RAG snippets shown as "what the AI used".
  final List<String> contextUsed;

  final String? statusMessage;
  final String? question;

  bool get usedOnDeviceModel => source == 'onDevice';
}
