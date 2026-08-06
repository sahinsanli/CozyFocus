import 'dart:async';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/decoration_item.dart';
import '../models/app_progress.dart';
import '../models/sound_item.dart';
import 'audio_service.dart';
import 'progress_repository.dart';
import 'sound_effect_service.dart';

enum FocusTimerStatus { idle, running, paused, complete }

class AppController extends ChangeNotifier {
  AppController(
    SharedPreferences preferences, {
    AudioService? audioService,
    ProgressRepository? progressRepository,
    SoundEffectService? soundEffectService,
  }) : _audioService = audioService ?? MockAudioService(),
       _progressRepository =
           progressRepository ??
           SharedPreferencesProgressRepository(preferences),
       _soundEffectService = soundEffectService ?? MockSoundEffectService();

  final AudioService _audioService;
  final ProgressRepository _progressRepository;
  final SoundEffectService _soundEffectService;
  Timer? _ticker;
  int? _timerEndEpochMs;

  String username = 'Selin';
  bool darkMode = false;
  bool focusReminders = true;
  bool autoStartBreaks = false;
  bool testMode = true;
  bool testPreviewActive = false;
  int dailyGoalMinutes = 120;
  int defaultFocusMinutes = 25;
  int shortBreakMinutes = 5;

  FocusTimerStatus timerStatus = FocusTimerStatus.idle;
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

  final Map<String, double> soundVolumes = {
    for (final sound in soundCatalog) sound.id: 0,
  };
  final Map<String, double> _storedSoundVolumes = {
    for (final sound in soundCatalog) sound.id: 0,
  };
  String? audioErrorMessage;
  int sleepTimerMinutes = 30;

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

  bool isDecorationUnlocked(DecorationItem item) =>
      testMode ||
      inventoryEntries[item.id]?.status != InventoryStatus.locked ||
      allTimeMinutes >= item.unlockMinutes;

  int get unlockedDecorationCount =>
      decorationCatalog.where(isDecorationUnlocked).length;

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
    decorationPositions.addAll({
      for (final entry in progress.decorationPositions.entries)
        _currentDecorationId(entry.key): Offset(entry.value.x, entry.value.y),
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
        slotId: entry.value.slotId ?? item.defaultSlotId,
        layer: entry.value.layer == 0 ? item.layer.index : entry.value.layer,
        position: entry.value.position,
        interactionEnabled: entry.value.interactionEnabled,
      );
    }
    badgeProgress
      ..clear()
      ..addAll(progress.badges);
    dailyRewardState = progress.dailyReward;
    _storedSoundVolumes
      ..clear()
      ..addAll(progress.soundVolumes);
    _syncLegacyProgressModels();

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
          await _completeSession();
        } else {
          remainingSeconds = (delta / 1000).ceil();
          timerStatus = FocusTimerStatus.running;
          _startTicker();
        }
      }
    } else if (savedStatus == FocusTimerStatus.paused.name) {
      timerStatus = FocusTimerStatus.paused;
    }
    notifyListeners();
  }

  Future<void> startOrToggleTimer() async {
    testPreviewActive = false;
    switch (timerStatus) {
      case FocusTimerStatus.idle:
      case FocusTimerStatus.complete:
        showCelebration = false;
        activeSessionMinutes = defaultFocusMinutes;
        if (timerStatus == FocusTimerStatus.complete || remainingSeconds <= 0) {
          remainingSeconds = activeSessionMinutes * 60;
        }
        timerStatus = FocusTimerStatus.running;
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
    activeSessionMinutes = defaultFocusMinutes;
    remainingSeconds = defaultFocusMinutes * 60;
    timerStatus = FocusTimerStatus.idle;
    showCelebration = false;
    testPreviewActive = false;
    await _persistTimer();
    notifyListeners();
  }

  void dismissCelebration() {
    showCelebration = false;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    var developmentStage = (timerProgress * 4).floor();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        _ticker?.cancel();
        await _completeSession();
      } else {
        remainingSeconds--;
        final nextStage = (timerProgress * 4).floor();
        if (nextStage > developmentStage && nextStage < 4) {
          developmentStage = nextStage;
          unawaited(_playDevelopmentEffect());
        }
        notifyListeners();
      }
    });
  }

  Future<void> _completeSession({bool recordProgress = true}) async {
    _ticker?.cancel();
    final minutes = activeSessionMinutes;
    if (recordProgress) {
      final key = _dateKey(DateTime.now());
      _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    }
    timerStatus = FocusTimerStatus.complete;
    remainingSeconds = 0;
    lastRewardMinutes = minutes;
    showCelebration = true;
    unawaited(_playEffect(AppSoundEffect.claimReward));
    if (recordProgress) _syncLegacyProgressModels();
    await _persistTimer();
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
    }
    final previousStage = (timerProgress * 4).floor();
    remainingSeconds = (remainingSeconds - minutes * 60).clamp(
      0,
      activeSessionMinutes * 60,
    );
    if (remainingSeconds == 0) {
      await _completeSession(recordProgress: false);
      return;
    }
    timerStatus = FocusTimerStatus.paused;
    final nextStage = (timerProgress * 4).floor();
    if (nextStage > previousStage && nextStage < 4) {
      unawaited(_playDevelopmentEffect());
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
    testPreviewActive = true;
    remainingSeconds = 0;
    await _completeSession(recordProgress: false);
  }

  Future<void> setTestMode(bool value) async {
    if (testMode == value) return;
    testMode = value;
    await resetTimer();
  }

  @visibleForTesting
  Future<void> recordCompletedSession(int minutes, {DateTime? on}) async {
    final key = _dateKey(on ?? DateTime.now());
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
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
    layoutSaved = false;
    final added = !selectedDecorationIds.remove(id);
    if (added) {
      selectedDecorationIds.add(id);
      decorationPositions[id] = item.defaultPosition;
    }
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
    _persistedDecorationPositions[id] =
        decorationPositions[id] ?? item.defaultPosition;
    _syncLegacyProgressModels();
    _syncRoomPlacements();
    await _persistProgress();
    layoutSaved = true;
    if (added) unawaited(_playEffect(AppSoundEffect.puttingItem));
    notifyListeners();
  }

  Future<void> saveLayout() async {
    _persistedSelectedDecorationIds
      ..clear()
      ..addAll(selectedDecorationIds);
    _persistedDecorationPositions
      ..clear()
      ..addAll(decorationPositions);
    _syncLegacyProgressModels();
    _syncRoomPlacements();
    await _persistProgress();
    layoutSaved = true;
    notifyListeners();
  }

  void moveDecoration(String id, Offset position) {
    decorationPositions[id] = Offset(
      position.dx.clamp(-.88, .88),
      position.dy.clamp(-.80, .80),
    );
    layoutSaved = false;
    notifyListeners();
  }

  void finishMovingDecoration() {
    unawaited(_playEffect(AppSoundEffect.puttingItem));
  }

  Future<void> placeDecoration({
    required String id,
    required Offset position,
    required String slotId,
  }) async {
    final item = decorationCatalog.firstWhere((item) => item.id == id);
    final normalized = Offset(
      position.dx.clamp(-.88, .88),
      position.dy.clamp(-.80, .80),
    );
    decorationPositions[id] = normalized;
    _persistedDecorationPositions[id] = normalized;
    _persistedSelectedDecorationIds.add(id);
    roomPlacements[id] = RoomPlacement(
      itemId: id,
      slotId: slotId,
      layer: item.layer.index,
      position: NormalizedPosition(normalized.dx, normalized.dy),
      interactionEnabled: roomPlacements[id]?.interactionEnabled ?? false,
    );
    layoutSaved = true;
    await _persistProgress();
    unawaited(_playEffect(AppSoundEffect.puttingItem));
    notifyListeners();
  }

  bool isRoomItemActive(String id) =>
      roomPlacements[id]?.interactionEnabled ?? false;

  Future<void> toggleRoomItemInteraction(String id) async {
    final item = decorationCatalog.firstWhere((item) => item.id == id);
    if (!item.isInteractive || !selectedDecorationIds.contains(id)) return;
    final existing = roomPlacements[id];
    final position = decorationPositions[id] ?? item.defaultPosition;
    roomPlacements[id] = RoomPlacement(
      itemId: id,
      slotId: existing?.slotId ?? item.defaultSlotId,
      layer: item.layer.index,
      position: NormalizedPosition(position.dx, position.dy),
      interactionEnabled: !(existing?.interactionEnabled ?? false),
    );
    await _persistProgress();
    notifyListeners();
  }

  Future<void> playTapSound() => _playEffect(AppSoundEffect.click);

  AppSoundEffect? get developmentSoundEffect {
    final upcoming =
        decorationCatalog
            .where((item) => item.unlockMinutes > allTimeMinutes)
            .toList()
          ..sort((a, b) => a.unlockMinutes.compareTo(b.unlockMinutes));
    if (upcoming.isEmpty) return null;
    final item = upcoming.first;
    if (item.id == 'sleeping_cat') return AppSoundEffect.catMeow;
    if (item.category == 'Furniture') return AppSoundEffect.woodCut;
    return null;
  }

  Future<void> _playDevelopmentEffect() async {
    final effect = developmentSoundEffect;
    if (effect != null) await _playEffect(effect);
  }

  Future<void> _playEffect(AppSoundEffect effect) async {
    try {
      await _soundEffectService.play(effect);
    } catch (_) {
      // Sound feedback should never interrupt a focus session or interaction.
    }
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
      await _persistProgress();
      notifyListeners();
      return true;
    } catch (_) {
      soundVolumes[id] = 0;
      audioErrorMessage = 'This sound could not be played.';
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
      await _persistProgress();
      notifyListeners();
    } catch (_) {
      soundVolumes[id] = 0;
      _storedSoundVolumes[id] = 0;
      audioErrorMessage = 'The volume could not be changed.';
      notifyListeners();
    }
  }

  Future<void> stopAllSounds() async {
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
    await _persistProgress();
    notifyListeners();
  }

  Future<void> setUsername(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    username = trimmed;
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
      final existing = inventoryEntries[item.id];
      if (existing?.status == InventoryStatus.crafting ||
          existing?.status == InventoryStatus.pendingClaim) {
        continue;
      }
      final placed = _persistedSelectedDecorationIds.contains(item.id);
      final unlocked = placed || allTimeMinutes >= item.unlockMinutes;
      inventoryEntries[item.id] = InventoryEntry(
        itemId: item.id,
        status: !unlocked
            ? InventoryStatus.locked
            : placed
            ? InventoryStatus.placed
            : InventoryStatus.owned,
        earnedAt: existing?.earnedAt,
        claimedAt: existing?.claimedAt,
      );
    }

    for (final entry in const {
      'first_bloom': 25,
      'night_owl': 120,
      'deep_woods': 300,
      'zen_keeper': 600,
    }.entries) {
      final existing = badgeProgress[entry.key];
      badgeProgress[entry.key] = BadgeProgress(
        badgeId: entry.key,
        earnedAt:
            existing?.earnedAt ??
            (allTimeMinutes >= entry.value ? DateTime.now() : null),
        celebrationSeen: existing?.celebrationSeen ?? false,
      );
    }
  }

  void _syncRoomPlacements() {
    roomPlacements.removeWhere(
      (itemId, _) => !_persistedSelectedDecorationIds.contains(itemId),
    );
    for (final itemId in _persistedSelectedDecorationIds) {
      final item = decorationCatalog.firstWhere((item) => item.id == itemId);
      final position = _persistedDecorationPositions[itemId];
      final existing = roomPlacements[itemId];
      roomPlacements[itemId] = RoomPlacement(
        itemId: itemId,
        slotId: existing?.slotId ?? item.defaultSlotId,
        layer: item.layer.index,
        position: position == null
            ? null
            : NormalizedPosition(position.dx, position.dy),
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
      remainingSeconds: remainingSeconds,
      activeSessionMinutes: activeSessionMinutes,
      endEpochMs: _timerEndEpochMs,
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

  static String _currentDecorationId(String legacyId) => switch (legacyId) {
    'cactus' => 'potted_plant',
    'armchair' => 'chair',
    _ => legacyId,
  };

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_audioService.dispose());
    unawaited(_soundEffectService.dispose());
    super.dispose();
  }
}
