import 'package:hive_flutter/hive_flutter.dart';

/// Tracks whether the user has completed first-run onboarding.
abstract final class OnboardingService {
  static const _boxName = 'app_meta';
  static const _onboardingCompleteKey = 'onboarding_complete';

  static Future<void> ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box => Hive.box(_boxName);

  static bool isComplete() {
    if (!Hive.isBoxOpen(_boxName)) return false;
    return _box.get(_onboardingCompleteKey, defaultValue: false) as bool;
  }

  static Future<void> markComplete() async {
    await ensureInitialized();
    await _box.put(_onboardingCompleteKey, true);
  }

  static Future<void> reset() async {
    await ensureInitialized();
    await _box.put(_onboardingCompleteKey, false);
  }
}
