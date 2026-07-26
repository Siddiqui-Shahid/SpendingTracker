import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/ad_service.dart';
import '../services/firebase_service.dart';
import '../services/onboarding_service.dart';

/// Runs startup work in parallel after Hive is ready.
abstract final class AppBootstrapService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox('expense_database'),
      OnboardingService.ensureInitialized(),
    ]);

    await FirebaseService.initialize();

    // Warm up ads in the background — never block first paint on the SDK.
    unawaited(AdService.warmUp());

    if (kDebugMode) {
      debugPrint('App bootstrap complete');
    }
  }
}
