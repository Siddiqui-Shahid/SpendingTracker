import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../legal/legal_documents.dart';
import 'firebase_service.dart';

enum LegalDocumentType { privacyPolicy, termsOfService }

/// Loads Privacy Policy and Terms from Firebase Remote Config with local fallbacks.
abstract final class LegalService {
  static Future<void> refresh() async {
    try {
      await FirebaseService.remoteConfig.fetchAndActivate();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Legal Remote Config refresh failed: $e');
      }
      await FirebaseService.logError(e, stack);
    }
  }

  static String privacyPolicy() => _text(
        key: AppConfig.rcPrivacyPolicy,
        fallback: LegalDocuments.privacyPolicy,
      );

  static String termsOfService() => _text(
        key: AppConfig.rcTermsOfService,
        fallback: LegalDocuments.termsOfService,
      );

  static String lastUpdated(LegalDocumentType type) {
    final key = type == LegalDocumentType.privacyPolicy
        ? AppConfig.rcPrivacyPolicyUpdated
        : AppConfig.rcTermsUpdated;
    final fallback = type == LegalDocumentType.privacyPolicy
        ? LegalDocuments.privacyPolicyUpdated
        : LegalDocuments.termsUpdated;

    try {
      final value = FirebaseService.remoteConfig.getString(key).trim();
      return value.isNotEmpty ? value : fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String title(LegalDocumentType type) {
    return switch (type) {
      LegalDocumentType.privacyPolicy => 'Privacy Policy',
      LegalDocumentType.termsOfService => 'Terms of Service',
    };
  }

  static String body(LegalDocumentType type) {
    return switch (type) {
      LegalDocumentType.privacyPolicy => privacyPolicy(),
      LegalDocumentType.termsOfService => termsOfService(),
    };
  }

  static String _text({
    required String key,
    required String fallback,
  }) {
    try {
      final remote = FirebaseService.remoteConfig.getString(key).trim();
      return remote.isNotEmpty ? remote : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
