import 'dart:convert';

import 'package:cozy_focus/core/models/app_progress.dart';
import 'package:cozy_focus/core/models/decoration_item.dart';
import 'package:cozy_focus/core/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('versioned progress snapshot survives a complete round trip', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesProgressRepository(preferences);
    final earnedAt = DateTime.utc(2026, 8, 6, 12, 30);
    final progress = AppProgressV2(
      username: 'Maya',
      profileAvatarId: 'moonleaf',
      darkMode: true,
      focusReminders: false,
      autoStartBreaks: true,
      testMode: false,
      dailyGoalMinutes: 90,
      defaultFocusMinutes: 45,
      shortBreakMinutes: 10,
      sleepTimerMinutes: 60,
      dailyMinutes: const {'2026-08-06': 45},
      selectedDecorationIds: const ['desk'],
      decorationPositions: const {'desk': NormalizedPosition(.25, -.10)},
      soundVolumes: const {'rain': .4, 'piano': .7},
      timer: const TimerSnapshot(
        status: 'paused',
        remainingSeconds: 900,
        activeSessionMinutes: 45,
      ),
      craftProgress: const CraftProgress(
        activeItemId: 'desk',
        accumulatedMinutes: 15,
        carryoverMinutes: 5,
      ),
      inventory: {
        'desk': InventoryEntry(
          itemId: 'desk',
          status: InventoryStatus.pendingClaim,
          earnedAt: earnedAt,
        ),
      },
      pendingRewards: [
        PendingReward(
          id: 'reward-desk',
          kind: PendingRewardKind.craftedItem,
          itemId: 'desk',
          earnedAt: earnedAt,
        ),
      ],
      roomPlacements: const {
        'desk': RoomPlacement(
          itemId: 'desk',
          slotId: 'floor-center',
          layer: 2,
          position: NormalizedPosition(.25, -.10),
          interactionEnabled: true,
        ),
      },
      badges: {
        'first_bloom': BadgeProgress(
          badgeId: 'first_bloom',
          earnedAt: earnedAt,
          celebrationSeen: false,
        ),
      },
      dailyReward: const DailyRewardState(
        completedDateKey: '2026-08-06',
        pendingRewardId: 'daily-1',
        claimedItemIds: ['candle'],
        placedItemIds: ['candle'],
        placementInitialized: true,
      ),
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.toJson(), progress.toJson());
    final stored =
        jsonDecode(
              preferences.getString(
                SharedPreferencesProgressRepository.storageKey,
              )!,
            )
            as Map<String, dynamic>;
    expect(stored['schemaVersion'], AppProgressV2.schemaVersion);
  });

  test('legacy preferences migrate without deleting rollback data', () async {
    final positions = jsonEncode({
      'cactus': [.11, -.22],
      'bookshelf': [.33, .44],
    });
    SharedPreferences.setMockInitialValues({
      'username': 'Legacy Maya',
      'darkMode': true,
      'focusReminders': false,
      'autoStartBreaks': true,
      'testMode': false,
      'dailyGoalMinutes': 90,
      'defaultFocusMinutes': 45,
      'shortBreakMinutes': 10,
      'sleepTimerMinutes': 60,
      'dailyMinutes': jsonEncode({'2026-08-06': 150}),
      'selectedDecorations': ['armchair', 'bookshelf'],
      'decorationPositions': positions,
      'volume_rain': .55,
      'timerStatus': 'paused',
      'remainingSeconds': 800,
      'activeSessionMinutes': 45,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesProgressRepository(preferences);

    final migrated = await repository.load();

    expect(migrated.username, 'Legacy Maya');
    expect(migrated.darkMode, isTrue);
    expect(migrated.autoStartBreaks, isTrue);
    expect(migrated.dailyMinutes['2026-08-06'], 150);
    expect(migrated.soundVolumes['rain'], .55);
    expect(migrated.timer.status, 'paused');
    final bookshelf = decorationCatalog.firstWhere(
      (item) => item.id == 'bookshelf',
    );
    expect(
      migrated.decorationPositions['bookshelf']?.x,
      bookshelf.placement.position.dx,
    );
    expect(
      migrated.decorationPositions['bookshelf']?.y,
      bookshelf.placement.position.dy,
    );
    expect(migrated.roomPlacements['bookshelf']?.slotId, 'bookshelf_home');
    expect(migrated.inventory['bookshelf']?.status, InventoryStatus.placed);
    expect(migrated.inventory['chair']?.status, InventoryStatus.placed);
    expect(migrated.inventory['sleeping_cat']?.status, InventoryStatus.locked);
    expect(migrated.roomPlacements.keys, containsAll(['chair', 'bookshelf']));
    expect(migrated.badges['night_owl']?.earnedAt, isNotNull);

    expect(preferences.getString('username'), 'Legacy Maya');
    expect(preferences.getString('decorationPositions'), positions);
    expect(
      preferences.getString(SharedPreferencesProgressRepository.storageKey),
      isNotNull,
    );

    await preferences.setString('username', 'Changed legacy value');
    final secondLoad = await repository.load();
    expect(secondLoad.username, 'Legacy Maya');
  });

  test('corrupt versioned data is backed up before legacy recovery', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProgressRepository.storageKey: '{not valid json',
      'username': 'Recovered',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesProgressRepository(preferences);

    final recovered = await repository.load();

    expect(recovered.username, 'Recovered');
    final backupKeys = preferences
        .getKeys()
        .where(
          (key) => key.startsWith(
            SharedPreferencesProgressRepository.corruptBackupPrefix,
          ),
        )
        .toList();
    expect(backupKeys, hasLength(1));
    expect(preferences.getString(backupKeys.single), '{not valid json');
    expect(
      () => jsonDecode(
        preferences.getString(SharedPreferencesProgressRepository.storageKey)!,
      ),
      returnsNormally,
    );
  });
}
