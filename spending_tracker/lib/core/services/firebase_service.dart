import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';

/// Initializes Firebase, Crashlytics, and Remote Config.
abstract final class FirebaseService {
  static FirebaseRemoteConfig? _remoteConfig;

  static FirebaseRemoteConfig get remoteConfig {
    final config = _remoteConfig;
    if (config == null) {
      throw StateError('FirebaseService.initialize() must be called first.');
    }
    return config;
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    _remoteConfig = FirebaseRemoteConfig.instance;
    await _remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 1)
            : const Duration(hours: 1),
      ),
    );
    await _remoteConfig!.setDefaults(AppConfig.remoteConfigDefaults);
    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Remote Config fetch failed: $e');
      }
      await FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }

  static Future<void> logError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: fatal,
    );
  }

  static Future<void> setUserId(String? id) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(id ?? '');
  }
}
