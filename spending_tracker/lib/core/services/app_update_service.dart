import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../utils/balance_utils.dart';
import 'firebase_service.dart';

enum UpdateType { none, optional, forced }

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.type,
    this.message,
    this.storeUrl,
    this.currentVersion,
    this.latestVersion,
  });

  final UpdateType type;
  final String? message;
  final String? storeUrl;
  final String? currentVersion;
  final String? latestVersion;

  bool get shouldShow => type != UpdateType.none;
  bool get isForced => type == UpdateType.forced;
}

/// Checks Firebase Remote Config for optional and forced app updates.
abstract final class AppUpdateService {
  static Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final remoteConfig = FirebaseService.remoteConfig;
      await remoteConfig.fetchAndActivate();

      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version;
      final currentCode = parseVersionCode(current);

      final minVersion = _minVersionForPlatform(remoteConfig);
      final latestVersion = remoteConfig.getString(AppConfig.rcLatestVersion);
      final forceUpdate = remoteConfig.getBool(AppConfig.rcForceUpdate);
      final message = remoteConfig.getString(AppConfig.rcUpdateMessage);
      final storeUrl = _storeUrlForPlatform(remoteConfig);

      final minCode = parseVersionCode(minVersion);
      final latestCode = parseVersionCode(latestVersion);

      if (currentCode < 0) {
        return AppUpdateInfo(type: UpdateType.none, currentVersion: current);
      }

      if (minCode >= 0 && currentCode < minCode) {
        return AppUpdateInfo(
          type: UpdateType.forced,
          message: message.isNotEmpty
              ? message
              : 'This version is no longer supported. Please update ${AppConfig.appName}.',
          storeUrl: storeUrl,
          currentVersion: current,
          latestVersion: latestVersion,
        );
      }

      if (forceUpdate && latestCode >= 0 && currentCode < latestCode) {
        return AppUpdateInfo(
          type: UpdateType.forced,
          message: message,
          storeUrl: storeUrl,
          currentVersion: current,
          latestVersion: latestVersion,
        );
      }

      if (latestCode >= 0 && currentCode < latestCode) {
        return AppUpdateInfo(
          type: UpdateType.optional,
          message: message.isNotEmpty
              ? message
              : 'A new version of ${AppConfig.appName} is available.',
          storeUrl: storeUrl,
          currentVersion: current,
          latestVersion: latestVersion,
        );
      }

      return AppUpdateInfo(type: UpdateType.none, currentVersion: current);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Update check failed: $e');
      }
      await FirebaseService.logError(e, stack);
      return const AppUpdateInfo(type: UpdateType.none);
    }
  }

  static String _minVersionForPlatform(FirebaseRemoteConfig config) {
    if (Platform.isIOS) {
      return config.getString(AppConfig.rcMinVersionIos);
    }
    return config.getString(AppConfig.rcMinVersionAndroid);
  }

  static String _storeUrlForPlatform(FirebaseRemoteConfig config) {
    if (Platform.isIOS) {
      final url = config.getString(AppConfig.rcAppStoreUrl);
      return url.isNotEmpty ? url : AppConfig.appStoreUrl;
    }
    final url = config.getString(AppConfig.rcPlayStoreUrl);
    return url.isNotEmpty ? url : AppConfig.playStoreUrl;
  }

  static Future<bool> openStore(String? url) async {
    final target = Uri.tryParse(url ?? '');
    if (target == null) return false;
    return launchUrl(target, mode: LaunchMode.externalApplication);
  }
}
