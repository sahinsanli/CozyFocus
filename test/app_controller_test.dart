import 'dart:convert';

import 'package:cozy_focus/core/models/app_progress.dart';
import 'package:cozy_focus/core/models/decoration_item.dart';
import 'package:cozy_focus/core/services/app_controller.dart';
import 'package:cozy_focus/core/services/audio_service.dart';
import 'package:cozy_focus/core/services/progress_repository.dart';
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
    await controller.setTestMode(false);

    await controller.toggleDecoration('sleeping_cat');

    expect(controller.selectedDecorationIds, isNot(contains('sleeping_cat')));
  });

  test('test mode fast-forwards checkpoints and saves real progress', () async {
    final preferences = await SharedPreferences.getInstance();
    final effects = _TrackingSoundEffectService();
    final controller = AppController(preferences, soundEffectService: effects);
    await controller.setDefaultFocusMinutes(15);

    expect(controller.testMode, isTrue);
    expect(controller.unlockedDecorationCount, 0);
    await controller.advanceTestFocus(10);
    await Future<void>.delayed(Duration.zero);

    expect(controller.testPreviewActive, isTrue);
    expect(controller.testElapsedMinutes, 10);
    expect(controller.timerStatus, FocusTimerStatus.paused);
    expect(effects.played, isNot(contains(AppSoundEffect.woodCut)));
    expect(controller.allTimeMinutes, 0);

    await controller.completeTestFocus();
    expect(controller.showCelebration, isTrue);
    expect(effects.played, contains(AppSoundEffect.claimReward));
    expect(controller.allTimeMinutes, 15);
    expect(controller.craftProgress.accumulatedMinutes, 15);
  });

  test('test mode advances to the next crafted item after claim', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setDefaultFocusMinutes(30);

    await controller.completeTestFocus();

    expect(controller.inventoryStatus('desk'), InventoryStatus.pendingClaim);
    expect(controller.nextPendingReward?.itemId, 'desk');
    expect(controller.currentCraftItem?.id, 'chair');

    await controller.claimNextReward(place: false);
    expect(controller.inventoryStatus('desk'), InventoryStatus.owned);
    expect(controller.testPreviewActive, isFalse);
    expect(controller.currentCraftItem?.id, 'chair');

    await controller.advanceTestFocus(10);
    expect(controller.testElapsedMinutes, 10);
    expect(controller.previewCraftItem?.id, 'chair');
    expect(controller.previewCraftMinutes, 10);
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

  test(
    'language preference is device-local and defaults safely to English',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);
      await controller.restore();
      expect(controller.languageCode, 'en');

      await controller.setLanguageCode('tr');
      expect(preferences.getString('preferred_language_code'), 'tr');

      final restored = AppController(preferences);
      await restored.restore();
      expect(restored.languageCode, 'tr');

      await restored.setLanguageCode('unsupported');
      expect(restored.languageCode, 'en');
      expect(preferences.getString('preferred_language_code'), 'en');
    },
  );

  test(
    'extended duration settings persist and only reset an idle timer',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);

      await controller.setDailyGoal(480);
      await controller.setDefaultFocusMinutes(90);
      expect(controller.dailyGoalMinutes, 480);
      expect(controller.remainingSeconds, 90 * 60);

      await controller.startOrToggleTimer();
      final runningRemaining = controller.remainingSeconds;
      await controller.setDefaultFocusMinutes(75);
      expect(controller.remainingSeconds, runningRemaining);

      final restored = AppController(preferences);
      await restored.restore();
      expect(restored.dailyGoalMinutes, 480);
      expect(restored.defaultFocusMinutes, 75);
    },
  );

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

    await controller.recordCompletedSession(30);
    await controller.claimNextReward(place: false);
    await Future<void>.delayed(Duration.zero);
    effects.played.clear();
    await controller.playTapSound();
    await controller.toggleDecoration('desk');
    await Future<void>.delayed(Duration.zero);

    expect(effects.played, [AppSoundEffect.click, AppSoundEffect.puttingItem]);
  });

  test('only non-wood development effects play during focus', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    expect(controller.currentCraftItem?.id, 'desk');
    expect(controller.developmentSoundEffect, isNull);
    await controller.recordCompletedSession(1320);
    expect(controller.currentCraftItem?.id, 'sleeping_cat');
    expect(controller.developmentSoundEffect, AppSoundEffect.catMeow);
  });

  test(
    'wood cut plays when furniture is earned, not while it develops',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final effects = _TrackingSoundEffectService();
      final controller = AppController(
        preferences,
        soundEffectService: effects,
      );

      await controller.recordCompletedSession(10);
      await Future<void>.delayed(Duration.zero);
      expect(effects.played, isNot(contains(AppSoundEffect.woodCut)));

      effects.played.clear();
      await controller.recordCompletedSession(20);
      await Future<void>.delayed(Duration.zero);
      expect(controller.inventoryStatus('desk'), InventoryStatus.pendingClaim);
      expect(effects.played, contains(AppSoundEffect.woodCut));
    },
  );

  test('focus minutes craft ordered items and carry excess forward', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.recordCompletedSession(30);
    expect(controller.inventoryStatus('desk'), InventoryStatus.pendingClaim);
    expect(controller.currentCraftItem?.id, 'chair');
    expect(controller.pendingRewards.map((reward) => reward.itemId), ['desk']);

    await controller.recordCompletedSession(70);
    expect(controller.inventoryStatus('chair'), InventoryStatus.pendingClaim);
    expect(controller.currentCraftItem?.id, 'rug');
    expect(controller.craftProgress.accumulatedMinutes, 10);
    expect(controller.pendingRewards.map((reward) => reward.itemId), [
      'desk',
      'chair',
    ]);
  });

  test('claim and place updates inventory and room placement', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.recordCompletedSession(30);

    await controller.claimNextReward(place: true);

    expect(controller.inventoryStatus('desk'), InventoryStatus.placed);
    expect(controller.selectedDecorationIds, contains('desk'));
    expect(controller.roomPlacements['desk']?.slotId, 'desk_home');
    expect(controller.roomPlacementRequestId, 'desk');
    expect(controller.badgeProgress['first_claim']?.earnedAt, isNotNull);
  });

  test('daily goal creates one non-repeating reward per day', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setDailyGoal(30);

    await controller.recordCompletedSession(30);
    final dailyRewards = controller.pendingRewards
        .where((reward) => reward.kind == PendingRewardKind.dailyDecoration)
        .toList();
    expect(dailyRewards, hasLength(1));
    expect(controller.badgeProgress['first_daily_goal']?.earnedAt, isNotNull);

    await controller.recordCompletedSession(30);
    expect(
      controller.pendingRewards.where(
        (reward) => reward.kind == PendingRewardKind.dailyDecoration,
      ),
      hasLength(1),
    );
  });

  test('gentle goal rewards can be placed, stored, and restored', () async {
    final preferences = await SharedPreferences.getInstance();
    final effects = _TrackingSoundEffectService();
    final controller = AppController(preferences, soundEffectService: effects);
    await controller.setDailyGoal(30);
    await controller.recordCompletedSession(30, on: DateTime(2026, 8, 1));
    while (controller.nextPendingReward != null) {
      await controller.claimNextReward(place: true);
    }

    expect(controller.dailyRewardState.claimedItemIds, contains('tea_cup'));
    expect(controller.dailyRewardState.placedItemIds, contains('tea_cup'));
    expect(controller.selectedDecorationIds, contains('desk'));

    await controller.toggleCollectibleDecoration('tea_cup');
    expect(
      controller.dailyRewardState.placedItemIds,
      isNot(contains('tea_cup')),
    );

    final restored = AppController(preferences);
    await restored.restore();
    expect(restored.dailyRewardState.claimedItemIds, contains('tea_cup'));
    expect(restored.dailyRewardState.placedItemIds, isNot(contains('tea_cup')));

    await restored.toggleCollectibleDecoration('tea_cup');
    expect(restored.dailyRewardState.placedItemIds, contains('tea_cup'));
  });

  test('craft progress and pending claims survive restore', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.recordCompletedSession(45);

    final restored = AppController(preferences);
    await restored.restore();

    expect(restored.inventoryStatus('desk'), InventoryStatus.pendingClaim);
    expect(restored.currentCraftItem?.id, 'chair');
    expect(restored.craftProgress.accumulatedMinutes, 15);
    expect(restored.nextPendingReward?.itemId, 'desk');
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

  test(
    'sleep timer requires audio and stops the entire mix when done',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final audio = _TrackingAudioService({'rain', 'fire'});
      final controller = AppController(preferences, audioService: audio);

      expect(await controller.startSleepTimer(), isFalse);
      await controller.toggleSound('rain');
      await controller.toggleSound('fire');
      await controller.setSleepTimer(15);

      expect(await controller.startSleepTimer(), isTrue);
      expect(controller.sleepTimerActive, isTrue);
      expect(controller.sleepTimerRemainingSeconds, 15 * 60);

      await controller.completeSleepTimerNow();
      expect(controller.sleepTimerActive, isFalse);
      expect(controller.sleepTimerJustFinished, isTrue);
      expect(controller.soundVolumes.values, everyElement(0));
      expect(audio.playing, isEmpty);
    },
  );

  test(
    'auto-start break begins after accelerated focus and records it once',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);
      await controller.setAutoStartBreaks(true);

      await controller.completeTestFocus();

      expect(controller.showCelebration, isTrue);
      expect(controller.isBreakSession, isTrue);
      expect(controller.timerStatus, FocusTimerStatus.running);
      expect(controller.remainingSeconds, controller.shortBreakMinutes * 60);
      expect(controller.allTimeMinutes, controller.defaultFocusMinutes);

      await controller.continueAfterCelebration();
      expect(controller.testPreviewActive, isFalse);
      await controller.resetTimer();
    },
  );

  test('paused break and selected profile avatar survive restore', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setProfileAvatar('cat');
    await controller.startBreak();
    await controller.startOrToggleTimer();

    final restored = AppController(preferences);
    await restored.restore();

    expect(restored.profileAvatarId, 'cat');
    expect(restored.isBreakSession, isTrue);
    expect(restored.timerStatus, FocusTimerStatus.paused);
    expect(restored.allTimeMinutes, 0);
  });

  test(
    'legacy free-form room coordinates restore to canonical homes',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);
      await controller.recordCompletedSession(30);
      await controller.claimNextReward(place: true);

      final stored =
          jsonDecode(
                preferences.getString(
                  SharedPreferencesProgressRepository.storageKey,
                )!,
              )
              as Map<String, dynamic>;
      (stored['decorationPositions'] as Map<String, dynamic>)['desk'] = {
        'x': .82,
        'y': -.73,
      };
      final storedPlacement =
          (stored['roomPlacements'] as Map<String, dynamic>)['desk']
              as Map<String, dynamic>;
      storedPlacement['slotId'] = 'legacy-anywhere';
      storedPlacement['position'] = {'x': .82, 'y': -.73};
      await preferences.setString(
        SharedPreferencesProgressRepository.storageKey,
        jsonEncode(stored),
      );

      final restored = AppController(preferences);
      await restored.restore();
      final desk = decorationCatalog.first;

      expect(restored.decorationPositions['desk'], desk.placement.position);
      expect(restored.roomPlacements['desk']?.slotId, desk.placement.slotId);
    },
  );

  test('fixed tabletop home and interactive candle state persist', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.recordCompletedSession(675);
    for (var i = 0; i < 5; i++) {
      await controller.claimNextReward(place: false);
    }
    await controller.toggleDecoration('candle');
    await controller.toggleRoomItemInteraction('candle');

    final restored = AppController(preferences);
    await restored.restore();

    expect(restored.roomPlacements['candle']?.slotId, 'candle_on_desk');
    expect(restored.selectedDecorationIds, containsAll(['desk', 'candle']));
    expect(restored.isRoomItemActive('candle'), isTrue);
  });

  test('storing a support item also stores its placed dependents', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await controller.recordCompletedSession(675);
    for (var i = 0; i < 5; i++) {
      await controller.claimNextReward(place: false);
    }
    await controller.toggleDecoration('candle');
    expect(controller.selectedDecorationIds, containsAll(['desk', 'candle']));

    await controller.toggleDecoration('desk');

    expect(controller.selectedDecorationIds, isNot(contains('desk')));
    expect(controller.selectedDecorationIds, isNot(contains('candle')));
    expect(controller.inventoryStatus('desk'), InventoryStatus.owned);
    expect(controller.inventoryStatus('candle'), InventoryStatus.owned);
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
