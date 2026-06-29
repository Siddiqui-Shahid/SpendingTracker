import 'package:flutter/material.dart';

/// Shared helpers for parsing and displaying expense categories.
abstract final class CategoryUtils {
  /// Splits a stored expense name into emoji, category label, and title.
  static ({String? emoji, String? category, String title}) parseExpenseName(
    String name,
  ) {
    if (!name.contains(' - ')) {
      return (emoji: null, category: null, title: name);
    }

    final parts = name.split(' - ');
    var categoryPart = parts[0];
    final title = parts.sublist(1).join(' - ');
    String? emoji;

    if (categoryPart.contains(' ')) {
      final firstSpace = categoryPart.indexOf(' ');
      emoji = categoryPart.substring(0, firstSpace);
      categoryPart = categoryPart.substring(firstSpace + 1);
    }

    return (emoji: emoji, category: categoryPart, title: title);
  }

  /// Parses a stored category string like "🎓 Education".
  static ({String? emoji, String name}) parseCategoryStorage(String stored) {
    if (!stored.contains(' ')) {
      return (emoji: null, name: stored);
    }
    final firstSpace = stored.indexOf(' ');
    return (
      emoji: stored.substring(0, firstSpace),
      name: stored.substring(firstSpace + 1),
    );
  }

  /// Finds emoji for a plain category name using the stored category list.
  static String? emojiForCategoryName(
    String categoryName,
    List<String> storedCategories,
  ) {
    for (final stored in storedCategories) {
      final parsed = parseCategoryStorage(stored);
      if (parsed.name == categoryName && parsed.emoji != null) {
        return parsed.emoji;
      }
    }
    return null;
  }

  /// Counts transactions matching a full stored category label.
  static int transactionCountForCategory(
    String storedCategory,
    List<dynamic> expenses,
  ) {
    var count = 0;
    for (final expense in expenses) {
      final name = expense.name?.toString() ?? '';
      if (name.startsWith('$storedCategory -') || name == storedCategory) {
        count++;
      }
    }
    return count;
  }

  /// Legacy icon fallback when no emoji is stored.
  static IconData getCategoryIcon(String name) {
    final lowercaseName = name.toLowerCase();
    if (lowercaseName.contains('food') ||
        lowercaseName.contains('juice') ||
        lowercaseName.contains('grocery') ||
        lowercaseName.contains('restaurant')) {
      return Icons.restaurant_rounded;
    }
    if (lowercaseName.contains('education') ||
        lowercaseName.contains('school') ||
        lowercaseName.contains('college')) {
      return Icons.school_outlined;
    }
    if (lowercaseName.contains('netflix') ||
        lowercaseName.contains('spotify') ||
        lowercaseName.contains('prime') ||
        lowercaseName.contains('ott') ||
        lowercaseName.contains('entertainment') ||
        lowercaseName.contains('movie')) {
      return Icons.movie_rounded;
    }
    if (lowercaseName.contains('travel') || lowercaseName.contains('car')) {
      return Icons.directions_car_rounded;
    }
    if (lowercaseName.contains('shopping')) {
      return Icons.shopping_bag_rounded;
    }
    if (lowercaseName.contains('bill') || lowercaseName.contains('payment')) {
      return Icons.payments_rounded;
    }
    if (lowercaseName.contains('health') || lowercaseName.contains('medical')) {
      return Icons.medical_services_rounded;
    }
    if (lowercaseName.contains('fitness') || lowercaseName.contains('gym')) {
      return Icons.fitness_center_rounded;
    }
    if (lowercaseName.contains('coffee')) {
      return Icons.coffee_rounded;
    }
    if (lowercaseName.contains('work')) {
      return Icons.work_rounded;
    }
    return Icons.category_outlined;
  }

  /// Extracts category label from expense name (without emoji).
  static String extractCategory(String expenseName) {
    final parsed = parseExpenseName(expenseName);
    return parsed.category ?? 'Other';
  }

  /// Formats date and time for the add/edit transaction picker (12-hour + AM/PM).
  static String formatDateTime12Hour(DateTime dateTime) {
    final hour24 = dateTime.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12;
    final displayHour = hour12 == 0 ? 12 : hour12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '$displayHour:$minute $period';
  }

  /// Formats a transaction subtitle per Stitch spec (time + date).
  static String formatTransactionSubtitle(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    return '$hour:$minute · $day.$month.$year';
  }

  /// Groups a date into a section header label.
  static String dateSectionLabel(DateTime date, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == yesterday) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
