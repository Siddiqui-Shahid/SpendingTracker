import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/ad_config.dart';
import '../config/app_config.dart';
import 'firebase_service.dart';
import 'onboarding_service.dart';

/// Loads and shows AdMob units on Android, driven by Firebase Remote Config.
abstract final class AdService {
  static const _openCountKey = 'app_open_count';
  static const _defaultBannerWidth = 360;
  static const _preloadTimeout = Duration(seconds: 4);

  static bool _initialized = false;
  static Completer<void>? _initCompleter;
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAppOpen = false;
  static bool _appOpenPreloadInFlight = false;

  static final Map<int, AdSize> _bannerSizeCache = <int, AdSize>{};
  static final Map<String, BannerAd> _preloadedBanners = <String, BannerAd>{};
  static final Set<String> _bannerPreloadsInFlight = <String>{};

  static bool get isSupported => AdConfig.isAdsSupportedPlatform;

  static bool get isInitialized => _initialized;

  static Future<void> get whenInitialized {
    if (_initialized) return Future<void>.value();
    _initCompleter ??= Completer<void>();
    return _initCompleter!.future;
  }

  static bool get adsEnabled {
    if (!isSupported) return false;
    try {
      return FirebaseService.remoteConfig.getBool(AppConfig.rcAdsEnabled);
    } catch (_) {
      return true;
    }
  }

  static int get splashEveryNOpens {
    try {
      return FirebaseService.remoteConfig.getInt(
        AppConfig.rcAdsSplashEveryNOpens,
      );
    } catch (_) {
      return 3;
    }
  }

  static String get appOpenUnitId => AdConfig.resolveUnitId(
        _remoteUnitId(AppConfig.rcAdUnitAppOpen, AdConfig.androidAppOpen),
      );

  static String get bannerDashboardUnitId => AdConfig.resolveUnitId(
        _remoteUnitId(
          AppConfig.rcAdUnitBannerDashboard,
          AdConfig.androidBannerDashboard,
        ),
      );

  static String get bannerHistoryUnitId => AdConfig.resolveUnitId(
        _remoteUnitId(
          AppConfig.rcAdUnitBannerHistory,
          AdConfig.androidBannerHistory,
        ),
      );

  static String get bannerInsightsUnitId => AdConfig.resolveUnitId(
        _remoteUnitId(
          AppConfig.rcAdUnitBannerInsights,
          AdConfig.androidBannerInsights,
        ),
      );

  static String _remoteUnitId(String key, String fallback) {
    try {
      final value = FirebaseService.remoteConfig.getString(key).trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  static Future<void> initialize() async {
    if (!isSupported) {
      _completeInit();
      return;
    }
    if (_initialized) return;

    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: <String>[
            // Logged by the Ads SDK on first run — add your device hash here.
            '1AD1BF1A74D6F5C3023226BEA64F9D4C',
          ],
        ),
      );
    }

    await MobileAds.instance.initialize();
    _initialized = true;
    _completeInit();
    if (kDebugMode) {
      debugPrint(
        'AdService initialized (Android). '
        'Debug builds use Google test ad units — ads should still appear.',
      );
    }
  }

  static void _completeInit() {
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }
  }

  /// Initializes the SDK and preloads likely ad units without blocking UI.
  static Future<void> warmUp() async {
    if (!isSupported) return;
    await initialize();
    if (!adsEnabled) return;

    unawaited(preloadAppOpenAd());
    preloadBannersForTabs();
  }

  static Future<AdSize> resolveBannerSize(int width) async {
    final truncated = width.truncate();
    if (truncated <= 0) return AdSize.banner;

    final cached = _bannerSizeCache[truncated];
    if (cached != null) return cached;

    final adaptive = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      truncated,
    );
    final size = adaptive ?? AdSize.banner;
    _bannerSizeCache[truncated] = size;
    return size;
  }

  static void preloadBannersForTabs() {
    if (!adsEnabled || !isSupported || !_initialized) return;
    unawaited(preloadBanner(bannerDashboardUnitId));
    unawaited(preloadBanner(bannerHistoryUnitId));
    unawaited(preloadBanner(bannerInsightsUnitId));
  }

  static Future<void> preloadBanner(
    String unitId, {
    int width = _defaultBannerWidth,
  }) async {
    if (!adsEnabled || !isSupported || !_initialized) return;
    if (_preloadedBanners.containsKey(unitId) ||
        _bannerPreloadsInFlight.contains(unitId)) {
      return;
    }

    _bannerPreloadsInFlight.add(unitId);
    try {
      final size = await resolveBannerSize(width);
      final completer = Completer<void>();

      final banner = BannerAd(
        adUnitId: unitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _preloadedBanners[unitId] = ad as BannerAd;
            if (kDebugMode) {
              debugPrint('Preloaded banner: $unitId');
            }
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (kDebugMode) {
              debugPrint('Banner preload failed ($unitId): ${error.message}');
            }
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );

      await banner.load();
      await completer.future.timeout(_preloadTimeout, onTimeout: () {});
    } finally {
      _bannerPreloadsInFlight.remove(unitId);
    }
  }

  static ({BannerAd ad, AdSize size})? takePreloadedBanner(String unitId) {
    final ad = _preloadedBanners.remove(unitId);
    if (ad == null) return null;
    return (ad: ad, size: ad.size);
  }

  static Future<bool> recordOpenAndShouldShowSplash() async {
    if (!isSupported) return false;

    await OnboardingService.ensureInitialized();
    final box = Hive.box('app_meta');
    final count = (box.get(_openCountKey, defaultValue: 0) as int) + 1;
    await box.put(_openCountKey, count);

    if (!adsEnabled) return false;

    final interval = splashEveryNOpens;
    if (interval <= 0) return false;
    return count % interval == 0;
  }

  static Future<void> preloadAppOpenAd() async {
    if (!adsEnabled || !isSupported || !_initialized) return;
    if (_appOpenAd != null || _appOpenPreloadInFlight) return;

    _appOpenPreloadInFlight = true;
    try {
      final completer = Completer<void>();
      await AppOpenAd.load(
        adUnitId: appOpenUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd?.dispose();
            _appOpenAd = ad;
            if (kDebugMode) {
              debugPrint('Preloaded app-open ad');
            }
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              debugPrint('App open ad failed to load: $error');
            }
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future.timeout(_preloadTimeout, onTimeout: () {});
    } finally {
      _appOpenPreloadInFlight = false;
    }
  }

  /// Non-blocking: shows app-open ad over the current screen when due.
  static Future<void> showSplashAdIfNeeded() async {
    await whenInitialized;
    if (!adsEnabled) return;

    final shouldShow = await recordOpenAndShouldShowSplash();
    if (!shouldShow) return;

    if (_appOpenAd == null) {
      await preloadAppOpenAd();
    }

    final ad = _appOpenAd;
    if (ad == null) return;
    _appOpenAd = null;

    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingAppOpen = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          debugPrint('App open ad failed to show: $error');
        }
        ad.dispose();
        _isShowingAppOpen = false;
        unawaited(preloadAppOpenAd());
        if (!completer.isCompleted) completer.complete();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAppOpen = false;
        unawaited(preloadAppOpenAd());
        if (!completer.isCompleted) completer.complete();
      },
    );

    await ad.show();
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        _isShowingAppOpen = false;
      },
    );
  }

  static bool get isShowingAppOpenAd => _isShowingAppOpen;
}
