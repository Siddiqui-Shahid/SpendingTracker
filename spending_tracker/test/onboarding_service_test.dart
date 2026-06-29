import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:new_spendz/core/services/onboarding_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('zenspend_hive_test');
    Hive.init(tempDir.path);
    if (Hive.isBoxOpen('app_meta')) {
      await Hive.box('app_meta').close();
    }
    await Hive.openBox('app_meta');
    await OnboardingService.reset();
  });

  tearDown(() async {
    if (Hive.isBoxOpen('app_meta')) {
      await Hive.box('app_meta').close();
    }
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('onboarding starts incomplete and can be marked complete', () async {
    expect(OnboardingService.isComplete(), isFalse);
    await OnboardingService.markComplete();
    expect(OnboardingService.isComplete(), isTrue);
  });
}
