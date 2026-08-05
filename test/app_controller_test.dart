import 'package:cozy_focus/core/services/app_controller.dart';
import 'package:cozy_focus/core/services/audio_service.dart';
import 'package:cozy_focus/core/services/sound_effect_service.dart';
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
    final effects = _TrackingSoundEffectService();
    final controller = AppController(preferences, soundEffectService: effects);

    await controller.restore();

    expect(controller.timerStatus, FocusTimerStatus.complete);
    expect(controller.todayMinutes, 25);
    expect(controller.showCelebration, isTrue);
    expect(effects.played, contains(AppSoundEffect.claimReward));
  });

  test('interaction and placement effects use their mapped sounds', () async {
    final preferences = await SharedPreferences.getInstance();
    final effects = _TrackingSoundEffectService();
    final controller = AppController(preferences, soundEffectService: effects);

    await controller.playTapSound();
    await controller.toggleDecoration('bookshelf');
    controller.finishMovingDecoration();
    await Future<void>.delayed(Duration.zero);

    expect(effects.played, [
      AppSoundEffect.click,
      AppSoundEffect.puttingItem,
      AppSoundEffect.puttingItem,
    ]);
  });

  test('focus development maps cat and furniture effects', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    expect(controller.developmentSoundEffect, AppSoundEffect.catMeow);
    await controller.recordCompletedSession(50);
    expect(controller.developmentSoundEffect, isNull);
    await controller.recordCompletedSession(70);
    expect(controller.developmentSoundEffect, AppSoundEffect.woodCut);
  });

  test('sound mixer supports multiple active sounds and stop all', () async {
    final preferences = await SharedPreferences.getInstance();
    final audio = _TrackingAudioService({'rain', 'fire'});
    final controller = AppController(preferences, audioService: audio);

    await controller.toggleSound('rain');
    await controller.toggleSound('fire');
    expect(controller.soundVolumes['rain'], greaterThan(0));
    expect(controller.soundVolumes['fire'], greaterThan(0));
    expect(audio.playing, {'rain', 'fire'});

    expect(await controller.toggleSound('cafe'), isFalse);
    expect(controller.soundVolumes['cafe'], 0);

    await controller.stopAllSounds();
    expect(controller.soundVolumes.values, everyElement(0));
    expect(audio.playing, isEmpty);
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

class _TrackingAudioService implements AudioService {
  _TrackingAudioService(this.supported);

  final Set<String> supported;
  final Set<String> playing = {};
  final Map<String, double> volumes = {};

  @override
  bool supports(String id) => supported.contains(id);

  @override
  Future<void> play(String id, double volume) async {
    playing.add(id);
    volumes[id] = volume;
  }

  @override
  Future<void> pause(String id) async {
    playing.remove(id);
  }

  @override
  Future<void> setVolume(String id, double volume) async {
    volumes[id] = volume;
  }

  @override
  Future<void> stopAll() async {
    playing.clear();
  }

  @override
  Future<void> dispose() async {}
}

class _TrackingSoundEffectService implements SoundEffectService {
  final List<AppSoundEffect> played = [];

  @override
  Future<void> play(AppSoundEffect effect) async {
    played.add(effect);
  }

  @override
  Future<void> dispose() async {}
}
