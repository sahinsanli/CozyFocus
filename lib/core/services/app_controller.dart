import 'dart:async';
import 'dart:ui' show Offset;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/decoration_item.dart';
import '../models/app_progress.dart';
import '../models/badge_definition.dart';
import '../models/sound_item.dart';
import 'account_service.dart';
import 'audio_service.dart';
import 'firebase_progress_repository.dart';
import 'progress_repository.dart';
import 'sound_effect_service.dart';

enum FocusTimerStatus { idle, running, paused, complete }

enum TimerSessionKind { focus, shortBreak }

class AppController extends ChangeNotifier {
  AppController(
    SharedPreferences preferences, {
    AudioService? audioService,
    ProgressRepository? progressRepository,
    SoundEffectService? soundEffectService,
    AccountService? accountService,
  }) : _audioService = audioService ?? MockAudioService(),
       _progressRepository =
           progressRepository ??
           SharedPreferencesProgressRepository(preferences),
       _soundEffectService = soundEffectService ?? MockSoundEffectService() {
    _accountService = accountService;
    _initializeProductionState();
  }

  final AudioService _audioService;
  final ProgressRepository _progressRepository;
  final SoundEffectService _soundEffectService;
  late final AccountService? _accountService;
  Timer? _ticker;
  int? _timerEndEpochMs;
  Timer? _sleepTimerTicker;
  int? _sleepTimerEndEpochMs;
  String? _activeSessionId;

  bool accountBusy = false;
  String? accountError;

  String username = 'Selin';
  bool darkMode = true;
  bool focusReminders = true;
  bool autoStartBreaks = false;
  bool testMode = true;
  bool testPreviewActive = false;
  int dailyGoalMinutes = 120;
  int defaultFocusMinutes = 25;
  int shortBreakMinutes = 5;

  FocusTimerStatus timerStatus = FocusTimerStatus.idle;
  TimerSessionKind timerSessionKind = TimerSessionKind.focus;
  int remainingSeconds = 25 * 60;
  int activeSessionMinutes = 25;
  bool showCelebration = false;
  int lastRewardMinutes = 0;

  final Map<String, int> _dailyMinutes = {};
  final Set<String> selectedDecorationIds = {};
  final Set<String> _persistedSelectedDecorationIds = {};
  final Map<String, Offset> decorationPositions = {
    for (final item in decorationCatalog) item.id: item.defaultPosition,
  };
  final Map<String, Offset> _persistedDecorationPositions = {
    for (final item in decorationCatalog) item.id: item.defaultPosition,
  };
  bool layoutSaved = false;

  CraftProgress craftProgress = const CraftProgress();
  final Map<String, InventoryEntry> inventoryEntries = {
    for (final item in decorationCatalog)
      item.id: InventoryEntry(itemId: item.id, status: InventoryStatus.locked),
  };
  final List<PendingReward> pendingRewards = [];
  final Map<String, RoomPlacement> roomPlacements = {};
  final Map<String, BadgeProgress> badgeProgress = {};
  DailyRewardState dailyRewardState = const DailyRewardState();
  String profileAvatarId = 'moonleaf';
  String? roomPlacementRequestId;

  final Map<String, double> soundVolumes = {
    for (final sound in soundCatalog) sound.id: 0,
  };
  final Map<String, double> _storedSoundVolumes = {
    for (final sound in soundCatalog) sound.id: 0,
  };
  String? audioErrorMessage;
  int sleepTimerMinutes = 30;
  int sleepTimerRemainingSeconds = 0;
  bool sleepTimerActive = false;
  bool sleepTimerJustFinished = false;

  bool get isBreakSession => timerSessionKind == TimerSessionKind.shortBreak;

  CozyAccount? get account => _accountService?.currentAccount;
  bool get accountFeaturesAvailable => _accountService != null;
  bool get hasCloudAccount => account != null && !(account?.isGuest ?? true);
  CloudSyncState get cloudSyncState =>
      _progressRepository is AccountProgressRepository
      ? (_progressRepository as AccountProgressRepository).syncState
      : CloudSyncState.localOnly;
  DateTime? get lastSyncedAt => _progressRepository is AccountProgressRepository
      ? (_progressRepository as AccountProgressRepository).lastSyncedAt
      : null;
  String? get cloudSyncError => _progressRepository is AccountProgressRepository
      ? (_progressRepository as AccountProgressRepository).syncError
      : null;

  int get activeSoundCount =>
      soundVolumes.values.where((volume) => volume > 0).length;

  String get sleepTimerLabel {
    final minutes = sleepTimerRemainingSeconds ~/ 60;
    final seconds = sleepTimerRemainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  int get allTimeMinutes =>
      _dailyMinutes.values.fold(0, (sum, value) => sum + value);

  int get todayMinutes => _dailyMinutes[_dateKey(DateTime.now())] ?? 0;

  int get weeklyMinutes {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return _dailyMinutes[_dateKey(day)] ?? 0;
    }).fold(0, (sum, value) => sum + value);
  }

  List<int> get currentWeekMinutes {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (index) =>
          _dailyMinutes[_dateKey(monday.add(Duration(days: index)))] ?? 0,
    );
  }

  int get streakDays {
    var cursor = DateTime.now();
    if ((_dailyMinutes[_dateKey(cursor)] ?? 0) == 0) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while ((_dailyMinutes[_dateKey(cursor)] ?? 0) > 0) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  InventoryStatus inventoryStatus(String itemId) =>
      inventoryEntries[itemId]?.status ?? InventoryStatus.locked;

  bool isDecorationUnlocked(DecorationItem item) {
    final status = inventoryStatus(item.id);
    return status == InventoryStatus.owned || status == InventoryStatus.placed;
  }

  int get unlockedDecorationCount =>
      decorationCatalog.where(isDecorationUnlocked).length;

  DecorationItem? get currentCraftItem {
    final activeId = craftProgress.activeItemId;
    if (activeId == null) return null;
    for (final item in decorationCatalog) {
      if (item.id == activeId) return item;
    }
    return null;
  }

  double get currentCraftRatio {
    final required = craftProgress.requiredMinutes;
    if (required <= 0) return currentCraftItem == null ? 1 : 0;
    return (craftProgress.accumulatedMinutes / required).clamp(0, 1);
  }

  int get currentCraftVisualStage => craftProgress.visualStage.clamp(0, 4);

  _CraftPreviewState get _craftPreview {
    final item = currentCraftItem;
    if (item == null) return const _CraftPreviewState();
    var previewItem = item;
    var accumulated = craftProgress.accumulatedMinutes.toDouble();
    var extra =
        !isBreakSession &&
            (timerStatus == FocusTimerStatus.running ||
                timerStatus == FocusTimerStatus.paused)
        ? (activeSessionMinutes * 60 - remainingSeconds) / 60
        : 0.0;
    var index = decorationCatalog.indexOf(previewItem);
    while (extra > 0) {
      final remaining = previewItem.unlockMinutes - accumulated;
      if (extra < remaining || index == decorationCatalog.length - 1) {
        accumulated = (accumulated + extra).clamp(
          0,
          previewItem.unlockMinutes.toDouble(),
        );
        break;
      }
      extra -= remaining;
      index++;
      previewItem = decorationCatalog[index];
      accumulated = 0;
    }
    return _CraftPreviewState(
      item: previewItem,
      minutes: accumulated,
      ratio: previewItem.unlockMinutes == 0
          ? 1
          : accumulated / previewItem.unlockMinutes,
    );
  }

  DecorationItem? get previewCraftItem => _craftPreview.item;
  int get previewCraftMinutes => _craftPreview.minutes.floor();
  double get previewCraftRatio => _craftPreview.ratio;
  int get previewCraftVisualStage => _visualStage(_craftPreview.ratio);

  PendingReward? get nextPendingReward {
    for (final reward in pendingRewards) {
      if (reward.kind == PendingRewardKind.craftedItem) return reward;
    }
    return pendingRewards.isEmpty ? null : pendingRewards.first;
  }

  BadgeDefinition? get nextBadgeCelebration {
    for (final badge in badgeCatalog) {
      final progress = badgeProgress[badge.id];
      if (progress?.earnedAt != null && !(progress?.celebrationSeen ?? true)) {
        return badge;
      }
    }
    return null;
  }

  double get timerProgress {
    final total = activeSessionMinutes * 60;
    if (total == 0) return 0;
    return (1 - remainingSeconds / total).clamp(0, 1);
  }

  Future<void> restore() async {
    final progress = await _progressRepository.load();
    username = progress.username;
    profileAvatarId = progress.profileAvatarId;
    darkMode = progress.darkMode;
    focusReminders = progress.focusReminders;
    autoStartBreaks = progress.autoStartBreaks;
    testMode = progress.testMode;
    dailyGoalMinutes = progress.dailyGoalMinutes;
    defaultFocusMinutes = progress.defaultFocusMinutes;
    shortBreakMinutes = progress.shortBreakMinutes;
    sleepTimerMinutes = progress.sleepTimerMinutes;
    activeSessionMinutes = progress.timer.activeSessionMinutes;
    remainingSeconds = progress.timer.remainingSeconds;
    _timerEndEpochMs = progress.timer.endEpochMs;
    _activeSessionId = progress.timer.sessionId;
    timerSessionKind =
        TimerSessionKind.values
            .where((kind) => kind.name == progress.timer.sessionKind)
            .firstOrNull ??
        TimerSessionKind.focus;

    _dailyMinutes
      ..clear()
      ..addAll(progress.dailyMinutes);
    selectedDecorationIds
      ..clear()
      ..addAll(
        progress.selectedDecorationIds
            .map(_currentDecorationId)
            .where((id) => decorationCatalog.any((item) => item.id == id)),
      );
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
    // Room V3 has one catalog-owned home per item. Legacy free-form
    // coordinates are intentionally ignored so an old save cannot recreate an
    // overlapping or floating room.
    decorationPositions
      ..clear()
      ..addAll({
        for (final item in decorationCatalog) item.id: item.placement.position,
      });
    _persistedDecorationPositions
      ..clear()
      ..addAll(decorationPositions);
    craftProgress = progress.craftProgress;
    inventoryEntries.clear();
    for (final entry in progress.inventory.entries) {
      final itemId = _currentDecorationId(entry.key);
      if (!decorationCatalog.any((item) => item.id == itemId)) continue;
      inventoryEntries[itemId] = InventoryEntry(
        itemId: itemId,
        status: entry.value.status,
        earnedAt: entry.value.earnedAt,
        claimedAt: entry.value.claimedAt,
      );
    }
    pendingRewards
      ..clear()
      ..addAll(progress.pendingRewards);
    roomPlacements.clear();
    for (final entry in progress.roomPlacements.entries) {
      final itemId = _currentDecorationId(entry.key);
      if (!decorationCatalog.any((item) => item.id == itemId)) continue;
      final item = decorationCatalog.firstWhere((item) => item.id == itemId);
      roomPlacements[itemId] = RoomPlacement(
        itemId: itemId,
        slotId: item.placement.slotId,
        layer: item.placement.layer.index,
        position: NormalizedPosition(
          item.placement.position.dx,
          item.placement.position.dy,
        ),
        interactionEnabled: entry.value.interactionEnabled,
      );
    }
    badgeProgress
      ..clear()
      ..addAll(progress.badges);
    final validCollectibleIds = dailyDecorationCatalog
        .map((item) => item.id)
        .toSet();
    final claimedCollectibleIds = progress.dailyReward.claimedItemIds
        .where(validCollectibleIds.contains)
        .toSet();
    final restoredPlacedCollectibles = progress.dailyReward.placedItemIds
        .where(claimedCollectibleIds.contains)
        .toSet();
    dailyRewardState = progress.dailyReward.copyWith(
      claimedItemIds: claimedCollectibleIds.toList(),
      placedItemIds: progress.dailyReward.placementInitialized
          ? restoredPlacedCollectibles.toList()
          : claimedCollectibleIds.toList(),
      placementInitialized: true,
    );
    _storedSoundVolumes
      ..clear()
      ..addAll(progress.soundVolumes);
    _initializeProductionState();
    _repairPlacementDependencies();
    _syncLegacyProgressModels();
    _syncRoomPlacements();

    // Persisted volumes are preferences only. Playback never resumes without
    // an explicit user action after a cold start.
    for (final sound in soundCatalog) {
      soundVolumes[sound.id] = 0;
    }

    final savedStatus = progress.timer.status;
    if (savedStatus == FocusTimerStatus.running.name) {
      final end = progress.timer.endEpochMs;
      if (end != null) {
        final delta = end - DateTime.now().millisecondsSinceEpoch;
        if (delta <= 0) {
          if (isBreakSession) {
            await _completeBreak();
          } else {
            await _completeSession();
          }
        } else {
          remainingSeconds = (delta / 1000).ceil();
          timerStatus = FocusTimerStatus.running;
          _startTicker();
        }
      }
    } else if (savedStatus == FocusTimerStatus.paused.name) {
      timerStatus = FocusTimerStatus.paused;
    }
    // Rewrite legacy room coordinates using the canonical layout during the
    // first restore. Ownership and interaction state remain untouched.
    await _persistProgress();
    notifyListeners();
  }

  Future<void> startOrToggleTimer() async {
    testPreviewActive = false;
    switch (timerStatus) {
      case FocusTimerStatus.idle:
      case FocusTimerStatus.complete:
        showCelebration = false;
        timerSessionKind = TimerSessionKind.focus;
        activeSessionMinutes = defaultFocusMinutes;
        if (timerStatus == FocusTimerStatus.complete || remainingSeconds <= 0) {
          remainingSeconds = activeSessionMinutes * 60;
        }
        timerStatus = FocusTimerStatus.running;
        _activeSessionId = _newSessionId();
        _startTicker();
      case FocusTimerStatus.running:
        _ticker?.cancel();
        timerStatus = FocusTimerStatus.paused;
      case FocusTimerStatus.paused:
        timerStatus = FocusTimerStatus.running;
        _startTicker();
    }
    await _persistTimer();
    notifyListeners();
  }

  Future<void> resetTimer() async {
    _ticker?.cancel();
    timerSessionKind = TimerSessionKind.focus;
    activeSessionMinutes = defaultFocusMinutes;
    remainingSeconds = defaultFocusMinutes * 60;
    timerStatus = FocusTimerStatus.idle;
    _activeSessionId = null;
    showCelebration = false;
    testPreviewActive = false;
    await _persistTimer();
    notifyListeners();
  }

  void dismissCelebration() {
    showCelebration = false;
    notifyListeners();
  }

  Future<void> continueAfterCelebration() async {
    showCelebration = false;
    testPreviewActive = false;
    if (!isBreakSession) {
      timerSessionKind = TimerSessionKind.focus;
      activeSessionMinutes = defaultFocusMinutes;
      remainingSeconds = defaultFocusMinutes * 60;
      timerStatus = FocusTimerStatus.idle;
    }
    await _persistTimer();
    notifyListeners();
  }

  Future<void> startBreak() async {
    _ticker?.cancel();
    showCelebration = false;
    testPreviewActive = false;
    timerSessionKind = TimerSessionKind.shortBreak;
    activeSessionMinutes = shortBreakMinutes;
    remainingSeconds = shortBreakMinutes * 60;
    timerStatus = FocusTimerStatus.running;
    _activeSessionId = null;
    _startTicker();
    await _persistTimer();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    var preview = _craftPreview;
    var developmentStage = _visualStage(preview.ratio);
    var developmentItemId = preview.item?.id;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        _ticker?.cancel();
        if (isBreakSession) {
          await _completeBreak();
        } else {
          await _completeSession();
        }
      } else {
        remainingSeconds--;
        if (!isBreakSession) {
          preview = _craftPreview;
          final nextStage = _visualStage(preview.ratio);
          if (preview.item?.id == developmentItemId &&
              nextStage > developmentStage &&
              nextStage < 4) {
            developmentStage = nextStage;
            final item = preview.item;
            final effect = item == null ? null : _developmentEffectFor(item);
            if (effect != null) unawaited(_playEffect(effect));
          } else if (preview.item?.id != developmentItemId) {
            developmentItemId = preview.item?.id;
            developmentStage = nextStage;
          }
        }
        notifyListeners();
      }
    });
  }

  Future<void> _completeSession({bool recordProgress = true}) async {
    _ticker?.cancel();
    final minutes = activeSessionMinutes;
    final completedAt = DateTime.now();
    final completedSessionId = _activeSessionId ?? _newSessionId();
    if (recordProgress) {
      final key = _dateKey(DateTime.now());
      final previousToday = _dailyMinutes[key] ?? 0;
      _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
      _applyFocusMinutes(minutes);
      _maybeCreateDailyReward(
        dateKey: key,
        previousMinutes: previousToday,
        currentMinutes: _dailyMinutes[key]!,
      );
      _evaluateBadges(successfulFocus: true);
    }
    timerStatus = FocusTimerStatus.complete;
    remainingSeconds = 0;
    lastRewardMinutes = minutes;
    showCelebration = true;
    if (!recordProgress) unawaited(_playEffect(AppSoundEffect.claimReward));
    if (recordProgress) _syncLegacyProgressModels();
    if (autoStartBreaks) {
      timerSessionKind = TimerSessionKind.shortBreak;
      activeSessionMinutes = shortBreakMinutes;
      remainingSeconds = shortBreakMinutes * 60;
      timerStatus = FocusTimerStatus.running;
      _startTicker();
    }
    _activeSessionId = null;
    await _persistTimer();
    if (recordProgress && _progressRepository is AccountProgressRepository) {
      await (_progressRepository as AccountProgressRepository)
          .recordFocusSession(
            id: completedSessionId,
            minutes: minutes,
            completedAt: completedAt,
          );
    }
    notifyListeners();
  }

  Future<void> _completeBreak() async {
    _ticker?.cancel();
    timerSessionKind = TimerSessionKind.focus;
    activeSessionMinutes = defaultFocusMinutes;
    remainingSeconds = defaultFocusMinutes * 60;
    timerStatus = FocusTimerStatus.idle;
    _activeSessionId = null;
    showCelebration = false;
    await _persistTimer();
    unawaited(_playEffect(AppSoundEffect.click));
    notifyListeners();
  }

  int get testElapsedMinutes =>
      ((activeSessionMinutes * 60 - remainingSeconds) / 60).floor().clamp(
        0,
        activeSessionMinutes,
      );

  Future<void> advanceTestFocus(int minutes) async {
    if (!testMode || showCelebration) return;
    _ticker?.cancel();
    if (!testPreviewActive) {
      activeSessionMinutes = defaultFocusMinutes;
      remainingSeconds = activeSessionMinutes * 60;
      testPreviewActive = true;
      _activeSessionId ??= _newSessionId();
    }
    final previousPreview = _craftPreview;
    remainingSeconds = (remainingSeconds - minutes * 60).clamp(
      0,
      activeSessionMinutes * 60,
    );
    if (remainingSeconds == 0) {
      await _completeSession();
      return;
    }
    timerStatus = FocusTimerStatus.paused;
    final nextPreview = _craftPreview;
    final previousStage = _visualStage(previousPreview.ratio);
    final nextStage = _visualStage(nextPreview.ratio);
    if (previousPreview.item?.id == nextPreview.item?.id &&
        nextStage > previousStage &&
        nextStage < 4) {
      final item = nextPreview.item;
      final effect = item == null ? null : _developmentEffectFor(item);
      if (effect != null) unawaited(_playEffect(effect));
    }
    await _persistTimer();
    notifyListeners();
  }

  Future<void> completeTestFocus() async {
    if (!testMode) return;
    _ticker?.cancel();
    if (!testPreviewActive) {
      activeSessionMinutes = defaultFocusMinutes;
      remainingSeconds = activeSessionMinutes * 60;
    }
    _activeSessionId ??= _newSessionId();
    testPreviewActive = true;
    remainingSeconds = 0;
    await _completeSession();
  }

  Future<void> setTestMode(bool value) async {
    if (testMode == value) return;
    testMode = value;
    if (!value && sleepTimerMinutes == 1) sleepTimerMinutes = 15;
    await resetTimer();
  }

  @visibleForTesting
  Future<void> recordCompletedSession(int minutes, {DateTime? on}) async {
    final completedOn = on ?? DateTime.now();
    final key = _dateKey(completedOn);
    final previousMinutes = _dailyMinutes[key] ?? 0;
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    _applyFocusMinutes(minutes);
    _maybeCreateDailyReward(
      dateKey: key,
      previousMinutes: previousMinutes,
      currentMinutes: _dailyMinutes[key]!,
    );
    _evaluateBadges(successfulFocus: true);
    _syncLegacyProgressModels();
    await _persistProgress();
    notifyListeners();
  }

  Future<void> _persistTimer() async {
    if (timerStatus == FocusTimerStatus.running) {
      _timerEndEpochMs = DateTime.now()
          .add(Duration(seconds: remainingSeconds))
          .millisecondsSinceEpoch;
    } else {
      _timerEndEpochMs = null;
    }
    await _persistProgress();
  }

  Future<void> toggleDecoration(String id) async {
    final item = decorationCatalog.firstWhere((item) => item.id == id);
    if (!isDecorationUnlocked(item)) return;
    var added = false;
    if (!selectedDecorationIds.contains(id)) {
      added = _placeInCanonicalHome(item);
    } else {
      _storeWithDependents(item.id);
    }
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
    _syncLegacyProgressModels();
    _syncRoomPlacements();
    await _persistProgress();
    layoutSaved = true;
    if (added) unawaited(_playEffect(AppSoundEffect.puttingItem));
    notifyListeners();
  }

  bool _placeInCanonicalHome(DecorationItem item) {
    final supportId = item.placement.supportItemId;
    if (supportId != null && !selectedDecorationIds.contains(supportId)) {
      final support = decorationCatalog.firstWhere(
        (candidate) => candidate.id == supportId,
      );
      if (!isDecorationUnlocked(support) || !_placeInCanonicalHome(support)) {
        return false;
      }
    }
    selectedDecorationIds.add(item.id);
    decorationPositions[item.id] = item.placement.position;
    _persistedDecorationPositions[item.id] = item.placement.position;
    inventoryEntries[item.id] = inventoryEntries[item.id]!.copyWith(
      status: InventoryStatus.placed,
    );
    return true;
  }

  void _storeWithDependents(String itemId) {
    for (final dependent in decorationCatalog.where(
      (item) => item.placement.supportItemId == itemId,
    )) {
      if (selectedDecorationIds.contains(dependent.id)) {
        _storeWithDependents(dependent.id);
      }
    }
    final retainedCollectibles = dailyRewardState.placedItemIds.where((id) {
      final collectible = dailyDecorationCatalog.firstWhere(
        (item) => item.id == id,
      );
      return collectible.placement.supportItemId != itemId;
    }).toList();
    if (retainedCollectibles.length != dailyRewardState.placedItemIds.length) {
      dailyRewardState = dailyRewardState.copyWith(
        placedItemIds: retainedCollectibles,
        placementInitialized: true,
      );
    }
    selectedDecorationIds.remove(itemId);
    final existing = inventoryEntries[itemId];
    if (existing != null && existing.status == InventoryStatus.placed) {
      inventoryEntries[itemId] = existing.copyWith(
        status: InventoryStatus.owned,
      );
    }
  }

  bool isCollectiblePlaced(String id) =>
      dailyRewardState.placedItemIds.contains(id);

  bool canPlaceCollectible(CollectibleDecoration item) {
    if (!dailyRewardState.claimedItemIds.contains(item.id)) return false;
    final supportId = item.placement.supportItemId;
    if (supportId == null || selectedDecorationIds.contains(supportId)) {
      return true;
    }
    final support = decorationCatalog.firstWhere(
      (candidate) => candidate.id == supportId,
    );
    return isDecorationUnlocked(support);
  }

  bool _placeCollectibleInCanonicalHome(CollectibleDecoration item) {
    final supportId = item.placement.supportItemId;
    if (supportId != null && !selectedDecorationIds.contains(supportId)) {
      final support = decorationCatalog.firstWhere(
        (candidate) => candidate.id == supportId,
      );
      if (!isDecorationUnlocked(support) || !_placeInCanonicalHome(support)) {
        return false;
      }
    }
    dailyRewardState = dailyRewardState.copyWith(
      placedItemIds: {...dailyRewardState.placedItemIds, item.id}.toList(),
      placementInitialized: true,
    );
    return true;
  }

  Future<void> toggleCollectibleDecoration(String id) async {
    if (!dailyRewardState.claimedItemIds.contains(id)) return;
    final item = dailyDecorationCatalog.firstWhere((item) => item.id == id);
    var placed = false;
    if (isCollectiblePlaced(id)) {
      dailyRewardState = dailyRewardState.copyWith(
        placedItemIds: dailyRewardState.placedItemIds
            .where((placedId) => placedId != id)
            .toList(),
        placementInitialized: true,
      );
    } else {
      placed = _placeCollectibleInCanonicalHome(item);
    }
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
    _syncLegacyProgressModels();
    _syncRoomPlacements();
    await _persistProgress();
    layoutSaved = true;
    if (placed) unawaited(_playEffect(AppSoundEffect.puttingItem));
    notifyListeners();
  }

  void _repairPlacementDependencies() {
    for (final item in decorationCatalog) {
      if (!selectedDecorationIds.contains(item.id)) continue;
      final supportId = item.placement.supportItemId;
      if (supportId == null || selectedDecorationIds.contains(supportId)) {
        continue;
      }
      final support = decorationCatalog.firstWhere(
        (candidate) => candidate.id == supportId,
      );
      if (isDecorationUnlocked(support)) {
        _placeInCanonicalHome(support);
      } else {
        selectedDecorationIds.remove(item.id);
        final existing = inventoryEntries[item.id];
        if (existing != null) {
          inventoryEntries[item.id] = existing.copyWith(
            status: InventoryStatus.owned,
          );
        }
      }
    }
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
  }

  bool isRoomItemActive(String id) =>
      roomPlacements[id]?.interactionEnabled ?? false;

  Future<void> toggleRoomItemInteraction(String id) async {
    final item = decorationCatalog.firstWhere((item) => item.id == id);
    if (!item.isInteractive || !selectedDecorationIds.contains(id)) return;
    final existing = roomPlacements[id];
    final position = item.placement.position;
    roomPlacements[id] = RoomPlacement(
      itemId: id,
      slotId: item.placement.slotId,
      layer: item.placement.layer.index,
      position: NormalizedPosition(position.dx, position.dy),
      interactionEnabled: !(existing?.interactionEnabled ?? false),
    );
    await _persistProgress();
    notifyListeners();
  }

  Future<void> playTapSound() => _playEffect(AppSoundEffect.click);

  void acknowledgeRoomPlacementRequest() {
    roomPlacementRequestId = null;
  }

  AppSoundEffect? get developmentSoundEffect {
    final item = currentCraftItem;
    if (item == null) return null;
    return _developmentEffectFor(item);
  }

  AppSoundEffect? _developmentEffectFor(DecorationItem item) {
    if (item.id == 'sleeping_cat') return AppSoundEffect.catMeow;
    return null;
  }

  AppSoundEffect _earnedEffectFor(DecorationItem item) =>
      item.category == 'Furniture'
      ? AppSoundEffect.woodCut
      : AppSoundEffect.claimReward;

  Future<void> _playEffect(AppSoundEffect effect) async {
    try {
      await _soundEffectService.play(effect);
    } catch (error, stackTrace) {
      debugPrint('Sound effect $effect failed: $error\n$stackTrace');
      // Sound feedback should never interrupt a focus session or interaction.
    }
  }

  void _initializeProductionState() {
    for (final item in decorationCatalog) {
      inventoryEntries.putIfAbsent(
        item.id,
        () => InventoryEntry(itemId: item.id, status: InventoryStatus.locked),
      );
    }
    pendingRewards.removeWhere(
      (reward) => switch (reward.kind) {
        PendingRewardKind.craftedItem => !decorationCatalog.any(
          (item) => item.id == reward.itemId,
        ),
        PendingRewardKind.dailyDecoration => !dailyDecorationCatalog.any(
          (item) => item.id == reward.itemId,
        ),
      },
    );

    final active = currentCraftItem;
    if (active != null &&
        inventoryStatus(active.id) != InventoryStatus.pendingClaim &&
        inventoryStatus(active.id) != InventoryStatus.owned &&
        inventoryStatus(active.id) != InventoryStatus.placed) {
      final accumulated = craftProgress.accumulatedMinutes.clamp(
        0,
        active.unlockMinutes,
      );
      inventoryEntries[active.id] = inventoryEntries[active.id]!.copyWith(
        status: accumulated > 0
            ? InventoryStatus.crafting
            : InventoryStatus.locked,
      );
      craftProgress = CraftProgress(
        activeItemId: active.id,
        accumulatedMinutes: accumulated,
        carryoverMinutes: craftProgress.carryoverMinutes,
        requiredMinutes: active.unlockMinutes,
        visualStage: _visualStage(accumulated / active.unlockMinutes),
      );
      return;
    }
    _selectNextCraftItem(carryover: craftProgress.carryoverMinutes);
  }

  void _selectNextCraftItem({int carryover = 0}) {
    DecorationItem? next;
    for (final item in decorationCatalog) {
      final status = inventoryStatus(item.id);
      if (status == InventoryStatus.locked ||
          status == InventoryStatus.crafting) {
        next = item;
        break;
      }
    }
    if (next == null) {
      craftProgress = CraftProgress(carryoverMinutes: carryover);
      return;
    }
    inventoryEntries[next.id] = inventoryEntries[next.id]!.copyWith(
      status: carryover > 0 ? InventoryStatus.crafting : InventoryStatus.locked,
    );
    craftProgress = CraftProgress(
      activeItemId: next.id,
      accumulatedMinutes: 0,
      carryoverMinutes: carryover,
      requiredMinutes: next.unlockMinutes,
      visualStage: 0,
    );
  }

  void _applyFocusMinutes(int minutes) {
    if (minutes <= 0) return;
    var available = minutes + craftProgress.carryoverMinutes;
    craftProgress = CraftProgress(
      activeItemId: craftProgress.activeItemId,
      accumulatedMinutes: craftProgress.accumulatedMinutes,
      requiredMinutes: craftProgress.requiredMinutes,
      visualStage: craftProgress.visualStage,
    );

    while (available > 0 && currentCraftItem != null) {
      final item = currentCraftItem!;
      final before = craftProgress.accumulatedMinutes;
      final required = item.unlockMinutes;
      final used = available.clamp(0, required - before);
      final after = before + used;
      final beforeStage = _visualStage(before / required);
      final afterStage = _visualStage(after / required);
      available -= used;

      if (afterStage > beforeStage && after < required) {
        final effect = _developmentEffectFor(item);
        if (effect != null) unawaited(_playEffect(effect));
      }

      if (after >= required) {
        final earnedAt = DateTime.now();
        inventoryEntries[item.id] = InventoryEntry(
          itemId: item.id,
          status: InventoryStatus.pendingClaim,
          earnedAt: earnedAt,
        );
        if (!pendingRewards.any(
          (reward) =>
              reward.kind == PendingRewardKind.craftedItem &&
              reward.itemId == item.id,
        )) {
          pendingRewards.add(
            PendingReward(
              id: 'crafted-${item.id}-${earnedAt.millisecondsSinceEpoch}',
              kind: PendingRewardKind.craftedItem,
              itemId: item.id,
              earnedAt: earnedAt,
            ),
          );
        }
        unawaited(_playEffect(_earnedEffectFor(item)));
        _selectNextCraftItem(carryover: available);
        if (currentCraftItem == null) break;
        craftProgress = CraftProgress(
          activeItemId: craftProgress.activeItemId,
          accumulatedMinutes: craftProgress.accumulatedMinutes,
          carryoverMinutes: 0,
          requiredMinutes: craftProgress.requiredMinutes,
          visualStage: craftProgress.visualStage,
        );
      } else {
        inventoryEntries[item.id] = inventoryEntries[item.id]!.copyWith(
          status: InventoryStatus.crafting,
        );
        craftProgress = CraftProgress(
          activeItemId: item.id,
          accumulatedMinutes: after,
          requiredMinutes: required,
          visualStage: afterStage,
        );
      }
    }
  }

  void _maybeCreateDailyReward({
    required String dateKey,
    required int previousMinutes,
    required int currentMinutes,
  }) {
    if (previousMinutes >= dailyGoalMinutes ||
        currentMinutes < dailyGoalMinutes ||
        dailyRewardState.completedDateKey == dateKey) {
      return;
    }
    final claimed = dailyRewardState.claimedItemIds.toSet();
    final pendingDailyIds = pendingRewards
        .where((reward) => reward.kind == PendingRewardKind.dailyDecoration)
        .map((reward) => reward.itemId)
        .toSet();
    CollectibleDecoration? rewardItem;
    for (final item in dailyDecorationCatalog) {
      if (!claimed.contains(item.id) && !pendingDailyIds.contains(item.id)) {
        rewardItem = item;
        break;
      }
    }
    if (rewardItem == null) {
      dailyRewardState = dailyRewardState.copyWith(completedDateKey: dateKey);
      return;
    }
    final earnedAt = DateTime.now();
    final reward = PendingReward(
      id: 'daily-${rewardItem.id}-${earnedAt.millisecondsSinceEpoch}',
      kind: PendingRewardKind.dailyDecoration,
      itemId: rewardItem.id,
      earnedAt: earnedAt,
    );
    pendingRewards.add(reward);
    dailyRewardState = dailyRewardState.copyWith(
      completedDateKey: dateKey,
      pendingRewardId: reward.id,
    );
    _evaluateBadges(dailyGoal: true);
    unawaited(_playEffect(AppSoundEffect.claimReward));
  }

  Future<void> claimNextReward({required bool place}) async {
    final reward = nextPendingReward;
    if (reward == null) return;
    pendingRewards.removeWhere((entry) => entry.id == reward.id);
    if (reward.kind == PendingRewardKind.craftedItem) {
      final item = decorationCatalog.firstWhere(
        (item) => item.id == reward.itemId,
      );
      final claimedAt = DateTime.now();
      inventoryEntries[item.id] = inventoryEntries[item.id]!.copyWith(
        status: place ? InventoryStatus.placed : InventoryStatus.owned,
        claimedAt: claimedAt,
      );
      if (place) {
        final placed = _placeInCanonicalHome(item);
        if (!placed) {
          inventoryEntries[item.id] = inventoryEntries[item.id]!.copyWith(
            status: InventoryStatus.owned,
          );
        }
        _persistedSelectedDecorationIds
          ..clear()
          ..addAll(selectedDecorationIds);
        _syncRoomPlacements();
        if (placed) {
          roomPlacementRequestId = item.id;
          unawaited(_playEffect(AppSoundEffect.puttingItem));
        }
      }
      _evaluateBadges(itemClaim: true);
    } else {
      final claimed = {...dailyRewardState.claimedItemIds, reward.itemId};
      dailyRewardState = dailyRewardState.copyWith(
        claimedItemIds: claimed.toList(),
        clearPendingReward: dailyRewardState.pendingRewardId == reward.id,
        placementInitialized: true,
      );
      if (place) {
        final item = dailyDecorationCatalog.firstWhere(
          (item) => item.id == reward.itemId,
        );
        final placed = _placeCollectibleInCanonicalHome(item);
        if (placed) {
          _persistedSelectedDecorationIds
            ..clear()
            ..addAll(selectedDecorationIds);
          _syncLegacyProgressModels();
          _syncRoomPlacements();
          roomPlacementRequestId = item.id;
          unawaited(_playEffect(AppSoundEffect.puttingItem));
        }
      }
    }
    showCelebration = pendingRewards.isNotEmpty;
    if (!showCelebration) testPreviewActive = false;
    await _persistProgress();
    notifyListeners();
  }

  void _evaluateBadges({
    bool successfulFocus = false,
    bool itemClaim = false,
    bool dailyGoal = false,
    bool mixer = false,
  }) {
    var earnedNewBadge = false;
    final roomComplete = decorationCatalog.every((item) {
      final status = inventoryStatus(item.id);
      return status == InventoryStatus.owned ||
          status == InventoryStatus.placed;
    });
    for (final badge in badgeCatalog) {
      final existing = badgeProgress[badge.id];
      if (existing?.earnedAt != null) continue;
      final earned = switch (badge.criterion) {
        BadgeCriterion.firstFocus => successfulFocus,
        BadgeCriterion.firstClaim => itemClaim,
        BadgeCriterion.firstDailyGoal => dailyGoal,
        BadgeCriterion.soundMixer => mixer,
        BadgeCriterion.totalFocusMinutes => allTimeMinutes >= badge.threshold,
        BadgeCriterion.roomComplete => roomComplete,
      };
      badgeProgress[badge.id] = BadgeProgress(
        badgeId: badge.id,
        earnedAt: earned ? DateTime.now() : null,
        celebrationSeen: existing?.celebrationSeen ?? false,
      );
      earnedNewBadge = earnedNewBadge || earned;
    }
    if (earnedNewBadge) unawaited(_playEffect(AppSoundEffect.claimReward));
  }

  Future<void> markBadgeCelebrationSeen(String badgeId) async {
    final progress = badgeProgress[badgeId];
    if (progress == null || progress.earnedAt == null) return;
    badgeProgress[badgeId] = BadgeProgress(
      badgeId: badgeId,
      earnedAt: progress.earnedAt,
      celebrationSeen: true,
    );
    await _persistProgress();
    notifyListeners();
  }

  static int _visualStage(double progress) {
    if (progress >= 1) return 4;
    if (progress >= .75) return 3;
    if (progress >= .50) return 2;
    if (progress >= .25) return 1;
    return 0;
  }

  bool isSoundAvailable(String id) => _audioService.supports(id);

  Future<bool> toggleSound(String id) async {
    if (!_audioService.supports(id)) {
      audioErrorMessage = null;
      return false;
    }
    final current = soundVolumes[id] ?? 0;
    try {
      if (current > 0) {
        await _audioService.pause(id);
        soundVolumes[id] = 0;
      } else {
        await _audioService.play(id, .6);
        soundVolumes[id] = .6;
      }
      _storedSoundVolumes[id] = soundVolumes[id]!;
      audioErrorMessage = null;
      sleepTimerJustFinished = false;
      if (soundVolumes.values.where((volume) => volume > 0).length >= 2) {
        _evaluateBadges(mixer: true);
      }
      if (activeSoundCount == 0) _clearSleepTimerState();
      await _persistProgress();
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      soundVolumes[id] = 0;
      debugPrint('Ambience $id failed: $error\n$stackTrace');
      audioErrorMessage = kDebugMode
          ? 'This sound could not be played: $error'
          : 'This sound could not be played. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> setSoundVolume(String id, double value) async {
    if (!_audioService.supports(id)) return;
    final previous = soundVolumes[id] ?? 0;
    try {
      if (value == 0) {
        await _audioService.pause(id);
      } else if (previous == 0) {
        await _audioService.play(id, value);
      } else {
        await _audioService.setVolume(id, value);
      }
      soundVolumes[id] = value;
      _storedSoundVolumes[id] = value;
      audioErrorMessage = null;
      sleepTimerJustFinished = false;
      if (soundVolumes.values.where((volume) => volume > 0).length >= 2) {
        _evaluateBadges(mixer: true);
      }
      if (activeSoundCount == 0) _clearSleepTimerState();
      await _persistProgress();
      notifyListeners();
    } catch (error, stackTrace) {
      soundVolumes[id] = 0;
      _storedSoundVolumes[id] = 0;
      debugPrint('Ambience volume $id failed: $error\n$stackTrace');
      audioErrorMessage = kDebugMode
          ? 'The volume could not be changed: $error'
          : 'The volume could not be changed. Please try again.';
      notifyListeners();
    }
  }

  Future<void> stopAllSounds() async {
    _clearSleepTimerState();
    sleepTimerJustFinished = false;
    for (final id in soundVolumes.keys) {
      soundVolumes[id] = 0;
      _storedSoundVolumes[id] = 0;
    }
    await _audioService.stopAll();
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setSleepTimer(int minutes) async {
    sleepTimerMinutes = minutes;
    if (sleepTimerActive) _armSleepTimer();
    await _persistProgress();
    notifyListeners();
  }

  Future<bool> startSleepTimer() async {
    if (activeSoundCount == 0) return false;
    sleepTimerJustFinished = false;
    sleepTimerActive = true;
    sleepTimerRemainingSeconds = sleepTimerMinutes * 60;
    _armSleepTimer();
    await _persistProgress();
    notifyListeners();
    return true;
  }

  void _armSleepTimer() {
    _sleepTimerTicker?.cancel();
    sleepTimerActive = true;
    sleepTimerRemainingSeconds = sleepTimerMinutes * 60;
    _sleepTimerEndEpochMs = DateTime.now()
        .add(Duration(seconds: sleepTimerRemainingSeconds))
        .millisecondsSinceEpoch;
    _sleepTimerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final end = _sleepTimerEndEpochMs;
      if (end == null) return;
      final delta = end - DateTime.now().millisecondsSinceEpoch;
      if (delta <= 0) {
        unawaited(_finishSleepTimer());
      } else {
        sleepTimerRemainingSeconds = (delta / 1000).ceil();
        notifyListeners();
      }
    });
  }

  Future<void> cancelSleepTimer() async {
    _clearSleepTimerState();
    await _persistProgress();
    notifyListeners();
  }

  void _clearSleepTimerState() {
    _sleepTimerTicker?.cancel();
    _sleepTimerTicker = null;
    _sleepTimerEndEpochMs = null;
    sleepTimerActive = false;
    sleepTimerRemainingSeconds = 0;
  }

  Future<void> _finishSleepTimer() async {
    _clearSleepTimerState();
    for (final id in soundVolumes.keys) {
      soundVolumes[id] = 0;
      _storedSoundVolumes[id] = 0;
    }
    await _audioService.stopAll();
    sleepTimerJustFinished = true;
    await _persistProgress();
    notifyListeners();
  }

  @visibleForTesting
  Future<void> completeSleepTimerNow() => _finishSleepTimer();

  Future<void> setUsername(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    username = trimmed;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> continueWithGoogle() => _runAccountTransition(
    () => _accountService!.continueWithGoogle(),
    mergeCurrentProgress: true,
  );

  Future<void> createEmailAccount(String email, String password) =>
      _runAccountTransition(
        () => _accountService!.createEmailAccount(email, password),
        mergeCurrentProgress: true,
      );

  Future<void> signInWithEmail(String email, String password) =>
      _runAccountTransition(
        () => _accountService!.signInWithEmail(email, password),
        mergeCurrentProgress: true,
      );

  Future<void> sendPasswordReset(String email) async {
    final service = _accountService;
    if (service == null || accountBusy) return;
    accountBusy = true;
    accountError = null;
    notifyListeners();
    try {
      await service.sendPasswordReset(email);
    } catch (error) {
      accountError = _friendlyAccountError(error);
      rethrow;
    } finally {
      accountBusy = false;
      notifyListeners();
    }
  }

  Future<void> syncAccountNow() async {
    if (_progressRepository is! AccountProgressRepository || accountBusy) {
      return;
    }
    accountBusy = true;
    accountError = null;
    notifyListeners();
    try {
      await (_progressRepository as AccountProgressRepository)
          .mergeIntoCurrentAccount(_progressSnapshot());
      await restore();
    } catch (error) {
      accountError = _friendlyAccountError(error);
    } finally {
      accountBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final service = _accountService;
    if (service == null || accountBusy) return;
    accountBusy = true;
    accountError = null;
    notifyListeners();
    try {
      await service.signOutToGuest();
      await restore();
    } catch (error) {
      accountError = _friendlyAccountError(error);
    } finally {
      accountBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount({String? password}) async {
    final service = _accountService;
    if (service == null ||
        _progressRepository is! AccountProgressRepository ||
        accountBusy) {
      return;
    }
    accountBusy = true;
    accountError = null;
    notifyListeners();
    try {
      await service.reauthenticate(password: password);
      await (_progressRepository as AccountProgressRepository)
          .deleteCurrentUserData();
      await service.deleteCurrentAccount();
      await service.ensureGuest();
      await restore();
    } catch (error) {
      accountError = _friendlyAccountError(error);
      rethrow;
    } finally {
      accountBusy = false;
      notifyListeners();
    }
  }

  Future<void> _runAccountTransition(
    Future<CozyAccount> Function() action, {
    required bool mergeCurrentProgress,
  }) async {
    if (_accountService == null || accountBusy) return;
    accountBusy = true;
    accountError = null;
    final currentProgress = _progressSnapshot();
    notifyListeners();
    try {
      await action();
      if (mergeCurrentProgress &&
          _progressRepository is AccountProgressRepository) {
        await (_progressRepository as AccountProgressRepository)
            .mergeIntoCurrentAccount(currentProgress);
      }
      await restore();
    } catch (error) {
      accountError = _friendlyAccountError(error);
      rethrow;
    } finally {
      accountBusy = false;
      notifyListeners();
    }
  }

  static String _friendlyAccountError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' ||
        'wrong-password' => 'The email or password is incorrect.',
        'email-already-in-use' => 'An account already uses this email.',
        'weak-password' => 'Use a password with at least 6 characters.',
        'invalid-email' => 'Enter a valid email address.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Check your internet connection.',
        'password-required' =>
          error.message ?? 'Enter your password to continue.',
        _ => error.message ?? 'The account action could not be completed.',
      };
    }
    return 'The account action could not be completed. Please try again.';
  }

  Future<void> setProfileAvatar(String avatarId) async {
    if (!profileAvatarCatalog.any((avatar) => avatar.id == avatarId)) return;
    profileAvatarId = avatarId;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setFocusReminders(bool value) async {
    focusReminders = value;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setAutoStartBreaks(bool value) async {
    autoStartBreaks = value;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    dailyGoalMinutes = value;
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setDefaultFocusMinutes(int value) async {
    defaultFocusMinutes = value;
    if (timerStatus == FocusTimerStatus.idle) {
      activeSessionMinutes = value;
      remainingSeconds = value * 60;
      await _persistTimer();
    } else {
      await _persistProgress();
    }
    notifyListeners();
  }

  Future<void> setShortBreakMinutes(int value) async {
    shortBreakMinutes = value;
    await _persistProgress();
    notifyListeners();
  }

  void _syncLegacyProgressModels() {
    for (final item in decorationCatalog) {
      final existing =
          inventoryEntries[item.id] ??
          InventoryEntry(itemId: item.id, status: InventoryStatus.locked);
      final placed = _persistedSelectedDecorationIds.contains(item.id);
      inventoryEntries[item.id] = InventoryEntry(
        itemId: item.id,
        status: placed
            ? InventoryStatus.placed
            : existing.status == InventoryStatus.placed
            ? InventoryStatus.owned
            : existing.status,
        earnedAt: existing.earnedAt,
        claimedAt: existing.claimedAt,
      );
    }
    _evaluateBadges();
  }

  void _syncRoomPlacements() {
    roomPlacements.removeWhere(
      (itemId, _) => !_persistedSelectedDecorationIds.contains(itemId),
    );
    for (final itemId in _persistedSelectedDecorationIds) {
      final item = decorationCatalog.firstWhere((item) => item.id == itemId);
      final existing = roomPlacements[itemId];
      final position = item.placement.position;
      decorationPositions[itemId] = position;
      _persistedDecorationPositions[itemId] = position;
      roomPlacements[itemId] = RoomPlacement(
        itemId: itemId,
        slotId: item.placement.slotId,
        layer: item.placement.layer.index,
        position: NormalizedPosition(position.dx, position.dy),
        interactionEnabled: existing?.interactionEnabled ?? false,
      );
    }
  }

  AppProgressV2 _progressSnapshot() => AppProgressV2(
    username: username,
    profileAvatarId: profileAvatarId,
    darkMode: darkMode,
    focusReminders: focusReminders,
    autoStartBreaks: autoStartBreaks,
    testMode: testMode,
    dailyGoalMinutes: dailyGoalMinutes,
    defaultFocusMinutes: defaultFocusMinutes,
    shortBreakMinutes: shortBreakMinutes,
    sleepTimerMinutes: sleepTimerMinutes,
    dailyMinutes: Map.unmodifiable(_dailyMinutes),
    selectedDecorationIds: List.unmodifiable(_persistedSelectedDecorationIds),
    decorationPositions: {
      for (final entry in _persistedDecorationPositions.entries)
        entry.key: NormalizedPosition(entry.value.dx, entry.value.dy),
    },
    soundVolumes: Map.unmodifiable(_storedSoundVolumes),
    timer: TimerSnapshot(
      status: timerStatus.name,
      sessionKind: timerSessionKind.name,
      remainingSeconds: remainingSeconds,
      activeSessionMinutes: activeSessionMinutes,
      endEpochMs: _timerEndEpochMs,
      sessionId: _activeSessionId,
    ),
    craftProgress: craftProgress,
    inventory: Map.unmodifiable(inventoryEntries),
    pendingRewards: List.unmodifiable(pendingRewards),
    roomPlacements: Map.unmodifiable(roomPlacements),
    badges: Map.unmodifiable(badgeProgress),
    dailyReward: dailyRewardState,
  );

  Future<void> _persistProgress() =>
      _progressRepository.save(_progressSnapshot());

  String formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours h' : '${hours}h ${remainder}m';
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _newSessionId() =>
      'focus-${DateTime.now().microsecondsSinceEpoch}';

  static String _currentDecorationId(String legacyId) => switch (legacyId) {
    'armchair' => 'chair',
    _ => legacyId,
  };

  @override
  void dispose() {
    _ticker?.cancel();
    _sleepTimerTicker?.cancel();
    unawaited(_audioService.dispose());
    unawaited(_soundEffectService.dispose());
    super.dispose();
  }
}

class _CraftPreviewState {
  const _CraftPreviewState({this.item, this.minutes = 0, this.ratio = 1});

  final DecorationItem? item;
  final double minutes;
  final double ratio;
}
