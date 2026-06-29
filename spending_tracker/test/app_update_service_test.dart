import 'package:flutter_test/flutter_test.dart';
import 'package:new_spendz/core/services/app_update_service.dart';

void main() {
  test('AppUpdateInfo identifies forced updates', () {
    const forced = AppUpdateInfo(
      type: UpdateType.forced,
      message: 'Please update',
    );
    expect(forced.shouldShow, isTrue);
    expect(forced.isForced, isTrue);
  });

  test('optional update is not forced', () {
    const optional = AppUpdateInfo(type: UpdateType.optional);
    expect(optional.shouldShow, isTrue);
    expect(optional.isForced, isFalse);
  });

  test('none update is hidden', () {
    const none = AppUpdateInfo(type: UpdateType.none);
    expect(none.shouldShow, isFalse);
  });
}
