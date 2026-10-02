import 'package:flutter/material.dart';

import '../../Data/hive_database.dart';

/// Owns app appearance (light / dark / system) independently of expense data,
/// so theme toggles do not rebuild the entire expense-driven widget tree.
class ThemeController extends ChangeNotifier {
  ThemeController({HiveDataBase? database}) : _db = database ?? HiveDataBase();

  final HiveDataBase _db;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Loads persisted preference from Hive (call after boxes are open).
  void load() {
    _themeMode = _fromStored(_db.getThemeMode());
    notifyListeners();
  }

  /// Updates in-memory mode immediately; persists after the current frame.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _db.saveThemeMode(_toStored(mode));
    });
  }

  /// Resets to system after a full data wipe.
  void resetToSystem() {
    setThemeMode(ThemeMode.system);
  }

  static ThemeMode _fromStored(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static int _toStored(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}
