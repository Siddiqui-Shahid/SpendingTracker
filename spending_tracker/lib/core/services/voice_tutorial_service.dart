import 'package:hive_flutter/hive_flutter.dart';

/// Persists whether the voice-entry tutorial was shown once.
abstract final class VoiceTutorialService {
  static const _boxName = 'app_meta';
  static const _seenKey = 'voice_tutorial_seen';

  static Future<void> ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box => Hive.box(_boxName);

  static bool hasSeen() {
    if (!Hive.isBoxOpen(_boxName)) return false;
    return _box.get(_seenKey, defaultValue: false) as bool;
  }

  static Future<void> markSeen() async {
    await ensureInitialized();
    await _box.put(_seenKey, true);
  }
}
