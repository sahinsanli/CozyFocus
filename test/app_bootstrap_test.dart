import 'package:cozy_focus/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('debug fresh start clears old progress exactly once', () async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete_v1': true,
      'app_progress_v2': 'old-test-progress',
    });
    final preferences = await SharedPreferences.getInstance();

    expect(await prepareFreshDebugStart(preferences, enabled: true), isTrue);
    expect(preferences.getBool('onboarding_complete_v1'), isNull);
    expect(preferences.getString('app_progress_v2'), isNull);
    expect(preferences.getBool(debugFreshStartStorageKey), isTrue);

    await preferences.setString('kept-after-reset', 'yes');
    expect(await prepareFreshDebugStart(preferences, enabled: true), isFalse);
    expect(preferences.getString('kept-after-reset'), 'yes');
  });

  test('release mode never clears persisted progress', () async {
    SharedPreferences.setMockInitialValues({'app_progress_v2': 'keep-me'});
    final preferences = await SharedPreferences.getInstance();

    expect(await prepareFreshDebugStart(preferences, enabled: false), isFalse);
    expect(preferences.getString('app_progress_v2'), 'keep-me');
  });
}
