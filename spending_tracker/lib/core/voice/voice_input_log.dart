import 'package:flutter/foundation.dart';

import 'voice_transaction_parser.dart';

/// Debug logger for the voice → form pipeline.
///
/// Filter console with: `[VoiceInput]`
abstract final class VoiceInputLog {
  static const _tag = '[VoiceInput]';

  static void d(String message, [Map<String, Object?>? fields]) {
    if (!kDebugMode) return;
    if (fields == null || fields.isEmpty) {
      debugPrint('$_tag $message');
      return;
    }
    final details = fields.entries
        .map((e) => '${e.key}=${e.value}')
        .join(' | ');
    debugPrint('$_tag $message · $details');
  }

  static void draft(String stage, VoiceTransactionDraft draft) {
    d(
      stage,
      {
        'type': draft.type?.name ?? 'null',
        'amount': draft.amount?.toString() ?? 'null',
        'title': draft.title ?? 'null',
        'date': draft.date?.toIso8601String() ?? 'null',
        'category': draft.category ?? 'null',
        'noCategory': draft.noCategory,
        'hasAnyField': draft.hasAnyField,
        'missing': draft.missingRequired.join(','),
      },
    );
  }

  static void warn(String message, [Object? error]) {
    if (!kDebugMode) return;
    debugPrint('$_tag WARN $message${error != null ? ' · $error' : ''}');
  }
}
