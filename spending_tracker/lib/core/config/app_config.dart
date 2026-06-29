import '../legal/legal_documents.dart';

/// App-wide constants for store listings, legal pages, and support.
abstract final class AppConfig {
  static const String appName = 'ZenSpend';
  static const String packageName = 'com.zenspend.app';

  static const String supportEmail = 'hello@cyfur.in';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.zenspend.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id0000000000';

  /// Public URLs for App Store / Play Store listings (mirror in-app legal text).
  static const String privacyPolicyUrl = 'https://cyfur.in/zenspend/privacy';
  static const String termsOfServiceUrl = 'https://cyfur.in/zenspend/terms';

  /// Firebase Remote Config parameter keys.
  static const String rcMinVersionAndroid = 'min_version_android';
  static const String rcMinVersionIos = 'min_version_ios';
  static const String rcLatestVersion = 'latest_version';
  static const String rcForceUpdate = 'force_update';
  static const String rcUpdateMessage = 'update_message';
  static const String rcPlayStoreUrl = 'play_store_url';
  static const String rcAppStoreUrl = 'app_store_url';
  static const String rcPrivacyPolicy = 'privacy_policy';
  static const String rcTermsOfService = 'terms_of_service';
  static const String rcPrivacyPolicyUpdated = 'privacy_policy_updated';
  static const String rcTermsUpdated = 'terms_of_service_updated';
  static const String rcSupportEmail = 'support_email';

  /// Bundled defaults used until Remote Config fetch succeeds.
  static Map<String, dynamic> get remoteConfigDefaults => {
        rcMinVersionAndroid: '1.0.0',
        rcMinVersionIos: '1.0.0',
        rcLatestVersion: '1.0.0',
        rcForceUpdate: false,
        rcUpdateMessage:
            'A new version of ZenSpend is available. Please update for the best experience.',
        rcPlayStoreUrl: playStoreUrl,
        rcAppStoreUrl: appStoreUrl,
        rcSupportEmail: supportEmail,
        rcPrivacyPolicyUpdated: LegalDocuments.privacyPolicyUpdated,
        rcTermsUpdated: LegalDocuments.termsUpdated,
        rcPrivacyPolicy: LegalDocuments.privacyPolicy,
        rcTermsOfService: LegalDocuments.termsOfService,
      };
}
