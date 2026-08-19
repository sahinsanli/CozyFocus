import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_progress.dart';
import 'progress_repository.dart';

enum CloudSyncState { localOnly, syncing, synced, error }

abstract interface class AccountProgressRepository {
  CloudSyncState get syncState;
  DateTime? get lastSyncedAt;
  String? get syncError;

  Future<AppProgressV2> mergeIntoCurrentAccount(AppProgressV2 incoming);
  Future<void> recordFocusSession({
    required String id,
    required int minutes,
    required DateTime completedAt,
  });
  Future<void> deleteCurrentUserData();
}

class FirebaseProgressRepository
    implements ProgressRepository, AccountProgressRepository {
  FirebaseProgressRepository({
    required SharedPreferences preferences,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _preferences = preferences,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final SharedPreferences _preferences;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  CloudSyncState syncState = CloudSyncState.localOnly;
  @override
  DateTime? lastSyncedAt;
  @override
  String? syncError;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Firebase account is not initialized.');
    return uid;
  }

  SharedPreferencesProgressRepository _local(String uid) =>
      SharedPreferencesProgressRepository(
        _preferences,
        storageNamespace: uid,
        migrateGlobalProgress: true,
      );

  DocumentReference<Map<String, dynamic>> _progressDocument(String uid) =>
      _firestore.doc('users/$uid/state/progress');

  @override
  Future<AppProgressV2> load() => _loadAndMerge();

  @override
  Future<void> save(AppProgressV2 progress) async {
    final uid = _uid;
    await _local(uid).save(progress);
    await _writeCloud(uid, progress);
  }

  @override
  Future<AppProgressV2> mergeIntoCurrentAccount(AppProgressV2 incoming) =>
      _loadAndMerge(incoming: incoming);

  Future<AppProgressV2> _loadAndMerge({AppProgressV2? incoming}) async {
    final uid = _uid;
    final localRepository = _local(uid);
    final hasAccountLocalProgress = _preferences.containsKey(
      localRepository.resolvedStorageKey,
    );
    var merged = hasAccountLocalProgress || incoming == null
        ? await localRepository.load()
        : incoming;
    if (incoming != null && hasAccountLocalProgress) {
      merged = ProgressMerger.merge(incoming, merged);
    }
    syncState = CloudSyncState.syncing;
    try {
      final snapshot = await _progressDocument(uid).get();
      final cloudPayload = snapshot.data()?['progress'];
      if (cloudPayload is Map) {
        final cloud = AppProgressV2.fromJson(
          cloudPayload.map((key, value) => MapEntry(key.toString(), value)),
        );
        merged = ProgressMerger.merge(merged, cloud);
      }
      await localRepository.save(merged);
      await _writeCloud(uid, merged);
    } catch (error) {
      syncState = CloudSyncState.error;
      syncError = error.toString();
      await localRepository.save(merged);
    }
    return merged;
  }

  Future<void> _writeCloud(String uid, AppProgressV2 progress) async {
    syncState = CloudSyncState.syncing;
    try {
      final account = _auth.currentUser!;
      await _firestore.doc('users/$uid').set({
        'uid': uid,
        'email': account.email,
        'isAnonymous': account.isAnonymous,
        'providers': account.providerData
            .map((provider) => provider.providerId)
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _progressDocument(uid).set({
        'progress': _cloudPayload(progress),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      lastSyncedAt = DateTime.now();
      syncError = null;
      syncState = CloudSyncState.synced;
    } catch (error) {
      syncState = CloudSyncState.error;
      syncError = error.toString();
    }
  }

  @override
  Future<void> recordFocusSession({
    required String id,
    required int minutes,
    required DateTime completedAt,
  }) async {
    final uid = _uid;
    try {
      await _firestore.doc('users/$uid/focusSessions/$id').set({
        'minutes': minutes,
        'completedAt': Timestamp.fromDate(completedAt.toUtc()),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      syncState = CloudSyncState.error;
      syncError = error.toString();
    }
  }

  @override
  Future<void> deleteCurrentUserData() async {
    final uid = _uid;
    final sessions = await _firestore
        .collection('users/$uid/focusSessions')
        .get();
    var batch = _firestore.batch();
    var count = 0;
    for (final document in sessions.docs) {
      batch.delete(document.reference);
      count++;
      if (count == 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }
    batch.delete(_progressDocument(uid));
    batch.delete(_firestore.doc('users/$uid'));
    await batch.commit();
    final localRepository = _local(uid);
    await localRepository.clear();
    await localRepository.clearMigrationSourceIfOwned();
  }

  static Map<String, dynamic> _cloudPayload(AppProgressV2 progress) {
    final payload = progress.toJson();
    payload.remove('soundVolumes');
    payload.remove('timer');
    final settings = Map<String, dynamic>.from(
      payload['settings'] as Map<String, dynamic>,
    )..remove('testMode');
    payload['settings'] = settings;
    return payload;
  }
}

class ProgressMerger {
  const ProgressMerger._();

  static AppProgressV2 merge(AppProgressV2 local, AppProgressV2 cloud) {
    final dailyMinutes = <String, int>{...local.dailyMinutes};
    for (final entry in cloud.dailyMinutes.entries) {
      final current = dailyMinutes[entry.key] ?? 0;
      if (entry.value > current) dailyMinutes[entry.key] = entry.value;
    }

    final inventory = <String, InventoryEntry>{...local.inventory};
    for (final entry in cloud.inventory.entries) {
      final current = inventory[entry.key];
      if (current == null ||
          _statusRank(entry.value.status) > _statusRank(current.status)) {
        inventory[entry.key] = entry.value;
      }
    }

    final rewards = <String, PendingReward>{
      for (final reward in local.pendingRewards) reward.id: reward,
      for (final reward in cloud.pendingRewards) reward.id: reward,
    };
    final badges = <String, BadgeProgress>{...local.badges};
    for (final entry in cloud.badges.entries) {
      final current = badges[entry.key];
      final earnedAt = _earlier(current?.earnedAt, entry.value.earnedAt);
      badges[entry.key] = BadgeProgress(
        badgeId: entry.key,
        earnedAt: earnedAt,
        celebrationSeen:
            (current?.celebrationSeen ?? false) || entry.value.celebrationSeen,
      );
    }

    final claimed = {
      ...local.dailyReward.claimedItemIds,
      ...cloud.dailyReward.claimedItemIds,
    };
    final placed = {
      ...local.dailyReward.placedItemIds,
      ...cloud.dailyReward.placedItemIds,
    }.where(claimed.contains).toList();

    final selected = {
      ...local.selectedDecorationIds,
      ...cloud.selectedDecorationIds,
    }.toList();

    return AppProgressV2(
      username: cloud.username,
      profileAvatarId: cloud.profileAvatarId,
      darkMode: cloud.darkMode,
      focusReminders: cloud.focusReminders,
      autoStartBreaks: cloud.autoStartBreaks,
      testMode: local.testMode,
      dailyGoalMinutes: cloud.dailyGoalMinutes,
      defaultFocusMinutes: cloud.defaultFocusMinutes,
      shortBreakMinutes: cloud.shortBreakMinutes,
      sleepTimerMinutes: cloud.sleepTimerMinutes,
      dailyMinutes: dailyMinutes,
      selectedDecorationIds: selected,
      decorationPositions: {
        ...local.decorationPositions,
        ...cloud.decorationPositions,
      },
      soundVolumes: local.soundVolumes,
      timer: local.timer,
      craftProgress: _craftProgress(local, cloud, inventory),
      inventory: inventory,
      pendingRewards: rewards.values.toList(),
      roomPlacements: {...local.roomPlacements, ...cloud.roomPlacements},
      badges: badges,
      focusRituals:
          cloud.focusRituals.updatedAtEpochMs >=
              local.focusRituals.updatedAtEpochMs
          ? cloud.focusRituals
          : local.focusRituals,
      dailyReward: DailyRewardState(
        completedDateKey: _latestKey(
          local.dailyReward.completedDateKey,
          cloud.dailyReward.completedDateKey,
        ),
        pendingRewardId:
            cloud.dailyReward.pendingRewardId ??
            local.dailyReward.pendingRewardId,
        claimedItemIds: claimed.toList(),
        placedItemIds: placed,
        placementInitialized: true,
      ),
    );
  }

  static CraftProgress _craftProgress(
    AppProgressV2 local,
    AppProgressV2 cloud,
    Map<String, InventoryEntry> inventory,
  ) {
    final cloudId = cloud.craftProgress.activeItemId;
    final localId = local.craftProgress.activeItemId;
    if (cloudId == localId) {
      return cloud.craftProgress.accumulatedMinutes >=
              local.craftProgress.accumulatedMinutes
          ? cloud.craftProgress
          : local.craftProgress;
    }
    if (cloudId != null &&
        inventory[cloudId]?.status == InventoryStatus.crafting) {
      return cloud.craftProgress;
    }
    return local.craftProgress;
  }

  static int _statusRank(InventoryStatus status) => switch (status) {
    InventoryStatus.locked => 0,
    InventoryStatus.crafting => 1,
    InventoryStatus.pendingClaim => 2,
    InventoryStatus.owned => 3,
    InventoryStatus.placed => 4,
  };

  static DateTime? _earlier(DateTime? first, DateTime? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.isBefore(second) ? first : second;
  }

  static String? _latestKey(String? first, String? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.compareTo(second) >= 0 ? first : second;
  }
}
