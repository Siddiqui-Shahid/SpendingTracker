import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob identifiers for FinTrack (Android production + Google test units).
abstract final class AdConfig {
  static const String androidAppId = 'ca-app-pub-3697710283934778~6564476712';

  static const String androidAppOpen = 'ca-app-pub-3697710283934778/3773863089';
  static const String androidBannerDashboard =
      'ca-app-pub-3697710283934778/7065828147';
  static const String androidBannerHistory =
      'ca-app-pub-3697710283934778/1819416499';
  static const String androidBannerInsights =
      'ca-app-pub-3697710283934778/6540425984';

  /// Google-provided test units — used in debug builds so you can verify ads
  /// without generating invalid traffic on production units.
  static const String testAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';

  /// Debug builds still show ads (Google test creatives). Production units are
  /// only used in release/profile builds.

  static bool get isAdsSupportedPlatform => !kIsWeb && Platform.isAndroid;

  static String resolveUnitId(String productionId) {
    if (kDebugMode) return _testIdForProduction(productionId);
    return productionId;
  }

  static String _testIdForProduction(String productionId) {
    if (productionId == androidAppOpen) return testAppOpen;
    return testBanner;
  }
}
