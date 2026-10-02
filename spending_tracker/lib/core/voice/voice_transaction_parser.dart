/// Parses spoken phrases into add-transaction draft fields.
///
/// Expected style (keywords can be in any order):
/// `expense amount 50 title lunch date 3 March category Food`
/// `income amount 1000 title salary date 15/03 category Salary`
library;

enum VoiceTransactionType { expense, income }

class VoiceTransactionDraft {
  const VoiceTransactionDraft({
    this.type,
    this.amount,
    this.title,
    this.date,
    this.category,
    this.noCategory = false,
    this.titleFromKeyword = false,
  });

  final VoiceTransactionType? type;
  final double? amount;
  final String? title;
  final DateTime? date;

  /// Resolved known category, or raw spoken name when unknown.
  final String? category;

  /// True when the user said “no category” / skipped category.
  final bool noCategory;

  /// True when title came from an explicit “title …” phrase.
  final bool titleFromKeyword;

  bool get hasCategory =>
      !noCategory && category != null && category!.trim().isNotEmpty;

  bool get hasAnyField =>
      type != null ||
      amount != null ||
      (title != null && title!.isNotEmpty) ||
      date != null ||
      hasCategory ||
      noCategory;

  List<String> get missingRequired {
    final missing = <String>[];
    if (type == null) missing.add('type');
    if (amount == null) missing.add('amount');
    if (title == null || title!.trim().isEmpty) missing.add('title');
    return missing;
  }

  /// Keeps previously heard fields; only overwrites when [incoming] has a value.
  VoiceTransactionDraft merge(VoiceTransactionDraft incoming) {
    final mergedNoCategory = noCategory || incoming.noCategory;
    final mergedCategory = mergedNoCategory
        ? null
        : (incoming.category ?? category);

    return VoiceTransactionDraft(
      type: incoming.type ?? type,
      amount: incoming.amount ?? amount,
      title: _mergeTitle(title, incoming),
      date: incoming.date ?? date,
      category: mergedCategory,
      noCategory: mergedNoCategory,
      titleFromKeyword: titleFromKeyword || incoming.titleFromKeyword,
    );
  }

  static String? _mergeTitle(
    String? current,
    VoiceTransactionDraft incoming,
  ) {
    final next = incoming.title?.trim();
    if (next == null || next.isEmpty) return current;
    if (VoiceTransactionParser.isJunkTitle(next)) return current;

    // Explicit "title …" always wins.
    if (incoming.titleFromKeyword) return next;

    if (current == null || current.trim().isEmpty) return next;

    final cur = current.trim();
    // Never replace a good title with a shorter fragment ("roti" → "1st").
    if (next.length < cur.length) return cur;
    // Avoid replacing with near-duplicates that only add junk ordinals.
    if (cur.toLowerCase() != next.toLowerCase() &&
        next.toLowerCase().startsWith(cur.toLowerCase())) {
      return next;
    }
    // Keep existing when incoming is unrelated short noise.
    if (next.split(RegExp(r'\s+')).length == 1 &&
        cur.isNotEmpty &&
        next.length <= 3) {
      return cur;
    }
    // Prefer keeping the established title unless incoming is clearly richer.
    if (next.toLowerCase() != cur.toLowerCase() &&
        next.length <= cur.length + 1) {
      return cur;
    }
    return next;
  }

  /// Human-readable guess shown while listening.
  String previewSummary({String symbol = '₹'}) {
    final parts = <String>[];
    if (type != null) {
      parts.add(type == VoiceTransactionType.income ? 'Income' : 'Expense');
    }
    if (amount != null) {
      final a = amount!;
      parts.add(
        '$symbol${a == a.roundToDouble() ? a.toInt() : a}',
      );
    }
    if (title != null && title!.trim().isNotEmpty) {
      parts.add(title!.trim());
    }
    if (date != null) {
      parts.add('${date!.day}/${date!.month}/${date!.year}');
    }
    if (noCategory) {
      parts.add('No category');
    } else if (hasCategory) {
      parts.add(category!);
    }
    if (parts.isEmpty) return 'Listening for transaction details…';
    return parts.join(' · ');
  }
}

abstract final class VoiceTransactionParser {
  static const _monthNames = <String, int>{
    'january': 1,
    'jan': 1,
    'february': 2,
    'feb': 2,
    'march': 3,
    'mar': 3,
    'april': 4,
    'apr': 4,
    'may': 5,
    'june': 6,
    'jun': 6,
    'july': 7,
    'jul': 7,
    'august': 8,
    'aug': 8,
    'september': 9,
    'sep': 9,
    'sept': 9,
    'october': 10,
    'oct': 10,
    'november': 11,
    'nov': 11,
    'december': 12,
    'dec': 12,
  };

  static const _stopWords = [
    'expense',
    'income',
    'spent',
    'spend',
    'received',
    'earn',
    'earned',
    'amount',
    'rupees',
    'rupee',
    'rs',
    'inr',
    'dollar',
    'dollars',
    'title',
    'label',
    'for',
    'date',
    'on',
    'category',
    'cat',
  ];

  static final _noCategoryPattern = RegExp(
    r'\b(?:no\s+category|without\s+category|skip\s+category|category\s+(?:none|skip)|none\s+category)\b',
    caseSensitive: false,
  );

  static final _finishCommandPattern = RegExp(
    r'^(done|finish|apply|submit|save|okay|ok)$',
    caseSensitive: false,
  );

  static final _junkTitlePattern = RegExp(
    r'^(done|finish|apply|submit|save|okay|ok|date|today|yesterday|category|cat|title|label|amount|expense|income|food|and|the|a|an|\d+(?:st|nd|rd|th)?)$',
    caseSensitive: false,
  );

  /// Spoken command to finish voice entry (not a title).
  static bool isFinishCommand(String raw) {
    return _finishCommandPattern.hasMatch(raw.trim());
  }

  static bool isJunkTitle(String value) {
    final t = value.trim().toLowerCase();
    if (t.isEmpty) return true;
    if (_junkTitlePattern.hasMatch(t)) return true;
    if (_monthNames.containsKey(t)) return true;
    return false;
  }

  static VoiceTransactionDraft parse(
    String raw, {
    DateTime? now,
    List<String> knownCategories = const [],
  }) {
    final reference = now ?? DateTime.now();
    final text = _normalize(raw);
    if (text.isEmpty) return const VoiceTransactionDraft();
    if (isFinishCommand(text)) return const VoiceTransactionDraft();

    final type = _parseType(text);
    final amount = _parseAmount(text);
    final date = _parseDate(text, reference);
    final explicitTitle =
        _parseLabeledValue(text, const ['title', 'label', 'for']);
    var title = explicitTitle;
    final titleFromKeyword =
        explicitTitle != null && explicitTitle.trim().isNotEmpty;
    final noCategory = _noCategoryPattern.hasMatch(text);
    String? category;
    if (!noCategory) {
      final spokenCategory =
          _parseLabeledValue(text, const ['category', 'cat']);
      category =
          _resolveCategory(spokenCategory, knownCategories) ?? spokenCategory;
    }

    // Natural title only between amount and the next field keyword; cap words.
    title ??=
        _parseBoundedNaturalTitle(text, knownCategories: knownCategories);
    if (!noCategory) {
      category ??= _parseNaturalCategory(
        text,
        knownCategories: knownCategories,
      );
    }

    if (title != null && isJunkTitle(title) && !titleFromKeyword) {
      title = null;
    }

    // Cap explicit titles too (avoid swallowing "title lunch date today…").
    if (title != null && !titleFromKeyword) {
      title = _capTitleWords(title);
    } else if (title != null && titleFromKeyword) {
      title = _capTitleWords(title, maxWords: 6);
    }

    return VoiceTransactionDraft(
      type: type,
      amount: amount,
      title: title,
      date: date,
      category: category,
      noCategory: noCategory,
      titleFromKeyword: titleFromKeyword,
    );
  }

  static const _maxNaturalTitleWords = 4;

  static String? _capTitleWords(String title, {int maxWords = _maxNaturalTitleWords}) {
    final parts = title
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty && !isJunkTitle(p))
        .take(maxWords)
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  /// Title words that sit after amount (or type) and before date/category keywords.
  static String? _parseBoundedNaturalTitle(
    String text, {
    required List<String> knownCategories,
  }) {
    // Prefer span after amount/number, before date/category stoppers.
    final afterAmount = RegExp(
      r'(?:amount|rupees?|rs|inr|dollars?)?\s*(\d+(?:[.,]\d{1,2})?)\s+(.+?)(?=\s+(?:date|today|yesterday|category|cat|no\s+category|without\s+category|done|finish|apply)\b|$)',
      caseSensitive: false,
    ).firstMatch(text);

    String? span;
    if (afterAmount != null) {
      span = afterAmount.group(2)?.trim();
    } else {
      // "expense 40 roti …" without the word amount
      final loose = RegExp(
        r'\b(?:expense|income|spent|spend)\s+(\d+(?:[.,]\d{1,2})?)\s+(.+?)(?=\s+(?:date|today|yesterday|category|cat|no\s+category|done|finish|apply)\b|$)',
        caseSensitive: false,
      ).firstMatch(text);
      span = loose?.group(2)?.trim();
    }
    if (span == null || span.isEmpty) return null;

    var cleaned = span
        .replaceAll(
          RegExp(
            r'\b(title|label|for|amount|expense|income|spent|spend)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\b\d+(?:[.,]\d{1,2})?\b'), ' ')
        .replaceAll(
          RegExp(r'\b\d+(?:st|nd|rd|th)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return null;

    final tokens = <String>[];
    for (final token in cleaned.split(' ')) {
      if (tokens.length >= _maxNaturalTitleWords) break;
      if (isJunkTitle(token)) continue;
      if (_resolveCategory(token, knownCategories) != null) continue;
      tokens.add(token);
    }
    if (tokens.isEmpty) return null;
    return tokens.join(' ');
  }

  static String? _parseNaturalCategory(
    String text, {
    required List<String> knownCategories,
  }) {
    // Trailing known category word, or after "category".
    final labeled = _parseLabeledValue(text, const ['category', 'cat']);
    if (labeled != null) {
      return _resolveCategory(labeled, knownCategories) ?? labeled;
    }

    final tokens = text.split(RegExp(r'\s+'));
    for (var i = tokens.length - 1; i >= 0; i--) {
      final match = _resolveCategory(tokens[i], knownCategories);
      if (match != null) return match;
    }
    return null;
  }

  /// Matches a spoken category against stored labels like `🍔 Food`.
  static String? matchKnownCategory(String? spoken, List<String> known) {
    if (spoken == null || spoken.trim().isEmpty) return null;
    return _resolveCategory(spoken, known);
  }

  static bool isKnownCategory(String? spoken, List<String> known) {
    return matchKnownCategory(spoken, known) != null;
  }

  static String _normalize(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s/.-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static VoiceTransactionType? _parseType(String text) {
    if (RegExp(r'\b(expense|spent|spend)\b').hasMatch(text)) {
      return VoiceTransactionType.expense;
    }
    if (RegExp(r'\b(income|received|earn|earned)\b').hasMatch(text)) {
      return VoiceTransactionType.income;
    }
    return null;
  }

  static double? _parseAmount(String text) {
    final labeled = RegExp(
      r'\b(?:amount|rupees?|rs|inr|dollars?)\s*(?:is|=|:)?\s*(\d+(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (labeled != null) {
      return double.tryParse(labeled.group(1)!.replaceAll(',', '.'));
    }

    final candidates = RegExp(r'\b(\d+(?:[.,]\d{1,2})?)\b').allMatches(text);
    for (final match in candidates) {
      final start = match.start;
      final before = text.substring(0, start);
      if (RegExp(r'\b(?:date|on)\s*$').hasMatch(before)) continue;
      if (RegExp(r'/\s*$').hasMatch(before)) continue;
      final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
      if (value != null) return value;
    }
    return null;
  }

  static String? _parseLabeledValue(String text, List<String> labels) {
    final labelAlt = labels.map(RegExp.escape).join('|');
    final stopAlt = _stopWords.map(RegExp.escape).join('|');
    final pattern = RegExp(
      '\\b(?:$labelAlt)\\s+(?:is\\s+|was\\s+)?(.+?)(?=\\s+(?:$stopAlt)\\b|\$)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    final value = match.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value
        .replaceAll(RegExp(r'\b(please|thanks|thank you)\b'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static DateTime? _parseDate(String text, DateTime reference) {
    if (RegExp(r'\btoday\b').hasMatch(text)) {
      return DateTime(reference.year, reference.month, reference.day);
    }
    if (RegExp(r'\byesterday\b').hasMatch(text)) {
      final y = reference.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day);
    }

    final labeled = RegExp(
      r'\b(?:date|on)\s+(.+?)(?=\s+(?:amount|title|label|for|category|cat|expense|income|spent|spend|received|earn|earned)\b|$)',
      caseSensitive: false,
    ).firstMatch(text);
    final candidate = labeled?.group(1)?.trim() ?? text;
    return _parseDateFragment(candidate, reference);
  }

  static DateTime? _parseDateFragment(String fragment, DateTime reference) {
    final numeric = RegExp(
      r'\b(\d{1,2})[\/\-.](\d{1,2})(?:[\/\-.](\d{2,4}))?\b',
    ).firstMatch(fragment);
    if (numeric != null) {
      final day = int.parse(numeric.group(1)!);
      final month = int.parse(numeric.group(2)!);
      final yearRaw = numeric.group(3);
      final year = yearRaw == null
          ? reference.year
          : (yearRaw.length == 2
              ? 2000 + int.parse(yearRaw)
              : int.parse(yearRaw));
      if (_isValidDate(year, month, day)) {
        return DateTime(year, month, day);
      }
    }

    // Prefer real month names so "40 roti" does not steal "1st august".
    final monthAlt = _monthNames.keys.map(RegExp.escape).join('|');
    final dayMonth = RegExp(
      '\\b(\\d{1,2})(?:st|nd|rd|th)?\\s+($monthAlt)(?:\\s+(\\d{2,4}))?\\b',
      caseSensitive: false,
    ).firstMatch(fragment);
    if (dayMonth != null) {
      final day = int.parse(dayMonth.group(1)!);
      final month = _monthNames[dayMonth.group(2)!.toLowerCase()];
      if (month != null) {
        final yearRaw = dayMonth.group(3);
        final year = yearRaw == null
            ? reference.year
            : (yearRaw.length == 2
                ? 2000 + int.parse(yearRaw)
                : int.parse(yearRaw));
        if (_isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }
    }

    final monthDay = RegExp(
      '\\b($monthAlt)\\s+(\\d{1,2})(?:st|nd|rd|th)?(?:\\s+(\\d{2,4}))?\\b',
      caseSensitive: false,
    ).firstMatch(fragment);
    if (monthDay != null) {
      final month = _monthNames[monthDay.group(1)!.toLowerCase()];
      final day = int.parse(monthDay.group(2)!);
      if (month != null) {
        final yearRaw = monthDay.group(3);
        final year = yearRaw == null
            ? reference.year
            : (yearRaw.length == 2
                ? 2000 + int.parse(yearRaw)
                : int.parse(yearRaw));
        if (_isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  static bool _isValidDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    try {
      final dt = DateTime(year, month, day);
      return dt.year == year && dt.month == month && dt.day == day;
    } catch (_) {
      return false;
    }
  }

  static String? _resolveCategory(String? spoken, List<String> known) {
    if (spoken == null || spoken.trim().isEmpty || known.isEmpty) return null;
    final needle = spoken.trim().toLowerCase();

    for (final stored in known) {
      final name = _categoryName(stored).toLowerCase();
      if (name == needle || stored.toLowerCase() == needle) {
        return stored;
      }
    }

    for (final stored in known) {
      final name = _categoryName(stored).toLowerCase();
      if (name.contains(needle) || needle.contains(name)) {
        return stored;
      }
    }
    return null;
  }

  static String _categoryName(String stored) {
    final trimmed = stored.trim();
    final space = trimmed.indexOf(' ');
    if (space <= 0) return trimmed;
    final maybeEmoji = trimmed.substring(0, space);
    if (maybeEmoji.runes.length <= 4 && !_looksLikeWord(maybeEmoji)) {
      return trimmed.substring(space + 1).trim();
    }
    return trimmed;
  }

  static bool _looksLikeWord(String value) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }
}
