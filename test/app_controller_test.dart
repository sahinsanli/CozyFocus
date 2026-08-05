import 'package:cozy_focus/core/services/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('completed sessions update all shared progress totals', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    final now = DateTime.now();

    await controller.recordCompletedSession(25, on: now);

    expect(controller.todayMinutes, 25);
    expect(controller.weeklyMinutes, 25);
    expect(controller.allTimeMinutes, 25);
    expect(controller.streakDays, 1);
  });

  test('locked room decorations cannot be selected', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.toggleDecoration('sleeping_cat');

    expect(controller.selectedDecorationIds, isNot(contains('sleeping_cat')));
  });

  test('timer transitions between running and paused safely', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.startOrToggleTimer();
    expect(controller.timerStatus, FocusTimerStatus.running);
    await controller.startOrToggleTimer();
    expect(controller.timerStatus, FocusTimerStatus.paused);
    await controller.startOrToggleTimer();
    expect(controller.timerStatus, FocusTimerStatus.running);

    await controller.resetTimer();
    expect(controller.timerStatus, FocusTimerStatus.idle);
  });

  test('settings and progress restore from local persistence', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setUsername('Maya');
    await controller.setDarkMode(true);
    await controller.recordCompletedSession(50);

    final restored = AppController(preferences);
    await restored.restore();

    expect(restored.username, 'Maya');
    expect(restored.darkMode, isTrue);
    expect(restored.allTimeMinutes, 50);
  });

  test('an elapsed running timer is safely recorded on restore', () async {
    SharedPreferences.setMockInitialValues({
      'timerStatus': FocusTimerStatus.running.name,
      'activeSessionMinutes': 25,
      'remainingSeconds': 20,
      'timerEndEpochMs': DateTime.now()
          .subtract(const Duration(seconds: 5))
          .millisecondsSinceEpoch,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.restore();

    expect(controller.timerStatus, FocusTimerStatus.complete);
    expect(controller.todayMinutes, 25);
    expect(controller.showCelebration, isTrue);
  });

  test('sound mixer supports multiple active sounds and stop all', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.toggleSound('rain');
    await controller.toggleSound('cafe');
    expect(controller.soundVolumes['rain'], greaterThan(0));
    expect(controller.soundVolumes['cafe'], greaterThan(0));

    await controller.stopAllSounds();
    expect(controller.soundVolumes.values, everyElement(0));
  });

  test('room decoration positions persist with the saved layout', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    controller.moveDecoration('cactus', const Offset(.24, .31));
    await controller.saveLayout();

    final restored = AppController(preferences);
    await restored.restore();

    expect(restored.decorationPositions['cactus'], const Offset(.24, .31));
  });
}
