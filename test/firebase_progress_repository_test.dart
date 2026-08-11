import 'package:cozy_focus/core/models/app_progress.dart';
import 'package:cozy_focus/core/services/firebase_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud merge preserves unlocks and local-only runtime state', () {
    final earnedAt = DateTime.utc(2026, 8, 10, 12);
    final local = AppProgressV2(
      username: 'Local guest',
      testMode: true,
      dailyMinutes: const {'2026-08-10': 45},
      soundVolumes: const {'rain': .7},
      timer: const TimerSnapshot(
        status: 'paused',
        remainingSeconds: 120,
        sessionId: 'focus-local',
      ),
      inventory: {
        'desk': InventoryEntry(
          itemId: 'desk',
          status: InventoryStatus.placed,
          earnedAt: earnedAt,
        ),
      },
      selectedDecorationIds: const ['desk'],
    );
    final cloud = AppProgressV2(
      username: 'Cloud account',
      darkMode: true,
      testMode: false,
      dailyMinutes: const {'2026-08-10': 25, '2026-08-09': 60},
      inventory: const {
        'desk': InventoryEntry(itemId: 'desk', status: InventoryStatus.owned),
        'chair': InventoryEntry(itemId: 'chair', status: InventoryStatus.owned),
      },
      selectedDecorationIds: const ['chair'],
    );

    final merged = ProgressMerger.merge(local, cloud);

    expect(merged.username, 'Cloud account');
    expect(merged.darkMode, isTrue);
    expect(merged.testMode, isTrue);
    expect(merged.timer.sessionId, 'focus-local');
    expect(merged.soundVolumes['rain'], .7);
    expect(merged.dailyMinutes, {'2026-08-10': 45, '2026-08-09': 60});
    expect(merged.inventory['desk']?.status, InventoryStatus.placed);
    expect(merged.inventory['chair']?.status, InventoryStatus.owned);
    expect(merged.selectedDecorationIds, containsAll(['desk', 'chair']));
  });

  test('pending rewards and badges merge without duplication', () {
    final earnedAt = DateTime.utc(2026, 8, 10, 12);
    final reward = PendingReward(
      id: 'reward-1',
      kind: PendingRewardKind.craftedItem,
      itemId: 'desk',
      earnedAt: earnedAt,
    );
    final local = AppProgressV2(
      pendingRewards: [reward],
      badges: {
        'first_focus': BadgeProgress(
          badgeId: 'first_focus',
          earnedAt: earnedAt,
        ),
      },
    );
    final cloud = AppProgressV2(
      pendingRewards: [reward],
      badges: const {
        'first_focus': BadgeProgress(
          badgeId: 'first_focus',
          celebrationSeen: true,
        ),
      },
    );

    final merged = ProgressMerger.merge(local, cloud);

    expect(merged.pendingRewards, hasLength(1));
    expect(merged.badges['first_focus']?.earnedAt, earnedAt);
    expect(merged.badges['first_focus']?.celebrationSeen, isTrue);
  });
}
