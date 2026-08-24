import 'focus_ritual.dart';

enum InventoryStatus { locked, crafting, pendingClaim, owned, placed }

enum PendingRewardKind { craftedItem, dailyDecoration }

class NormalizedPosition {
  const NormalizedPosition(this.x, this.y);

  final double x;
  final double y;

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory NormalizedPosition.fromJson(Map<String, dynamic> json) =>
      NormalizedPosition(
        (json['x'] as num?)?.toDouble() ?? 0,
        (json['y'] as num?)?.toDouble() ?? 0,
      );
}

class CraftProgress {
  const CraftProgress({
    this.activeItemId,
    this.accumulatedMinutes = 0,
    this.carryoverMinutes = 0,
    this.requiredMinutes = 0,
    this.visualStage = 0,
  });

  final String? activeItemId;
  final int accumulatedMinutes;
  final int carryoverMinutes;
  final int requiredMinutes;
  final int visualStage;

  Map<String, dynamic> toJson() => {
    'activeItemId': activeItemId,
    'accumulatedMinutes': accumulatedMinutes,
    'carryoverMinutes': carryoverMinutes,
    'requiredMinutes': requiredMinutes,
    'visualStage': visualStage,
  };

  factory CraftProgress.fromJson(Map<String, dynamic> json) => CraftProgress(
    activeItemId: json['activeItemId'] as String?,
    accumulatedMinutes: (json['accumulatedMinutes'] as num?)?.toInt() ?? 0,
    carryoverMinutes: (json['carryoverMinutes'] as num?)?.toInt() ?? 0,
    requiredMinutes: (json['requiredMinutes'] as num?)?.toInt() ?? 0,
    visualStage: (json['visualStage'] as num?)?.toInt() ?? 0,
  );
}

class InventoryEntry {
  const InventoryEntry({
    required this.itemId,
    required this.status,
    this.earnedAt,
    this.claimedAt,
  });

  final String itemId;
  final InventoryStatus status;
  final DateTime? earnedAt;
  final DateTime? claimedAt;

  InventoryEntry copyWith({
    InventoryStatus? status,
    DateTime? earnedAt,
    DateTime? claimedAt,
  }) => InventoryEntry(
    itemId: itemId,
    status: status ?? this.status,
    earnedAt: earnedAt ?? this.earnedAt,
    claimedAt: claimedAt ?? this.claimedAt,
  );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'status': status.name,
    'earnedAt': earnedAt?.toUtc().toIso8601String(),
    'claimedAt': claimedAt?.toUtc().toIso8601String(),
  };

  factory InventoryEntry.fromJson(Map<String, dynamic> json) => InventoryEntry(
    itemId: json['itemId'] as String? ?? '',
    status: InventoryStatus.values.byName(
      json['status'] as String? ?? InventoryStatus.locked.name,
    ),
    earnedAt: _date(json['earnedAt']),
    claimedAt: _date(json['claimedAt']),
  );
}

class PendingReward {
  const PendingReward({
    required this.id,
    required this.kind,
    required this.itemId,
    required this.earnedAt,
  });

  final String id;
  final PendingRewardKind kind;
  final String itemId;
  final DateTime earnedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'itemId': itemId,
    'earnedAt': earnedAt.toUtc().toIso8601String(),
  };

  factory PendingReward.fromJson(Map<String, dynamic> json) => PendingReward(
    id: json['id'] as String? ?? '',
    kind: PendingRewardKind.values.byName(
      json['kind'] as String? ?? PendingRewardKind.craftedItem.name,
    ),
    itemId: json['itemId'] as String? ?? '',
    earnedAt: _date(json['earnedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class RoomPlacement {
  const RoomPlacement({
    required this.itemId,
    this.slotId,
    this.layer = 0,
    this.position,
    this.interactionEnabled = false,
  });

  final String itemId;
  final String? slotId;
  final int layer;
  final NormalizedPosition? position;
  final bool interactionEnabled;

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'slotId': slotId,
    'layer': layer,
    'position': position?.toJson(),
    'interactionEnabled': interactionEnabled,
  };

  factory RoomPlacement.fromJson(Map<String, dynamic> json) => RoomPlacement(
    itemId: json['itemId'] as String? ?? '',
    slotId: json['slotId'] as String?,
    layer: (json['layer'] as num?)?.toInt() ?? 0,
    position: json['position'] is Map
        ? NormalizedPosition.fromJson(_stringMap(json['position']))
        : null,
    interactionEnabled: json['interactionEnabled'] as bool? ?? false,
  );
}

class BadgeProgress {
  const BadgeProgress({
    required this.badgeId,
    this.earnedAt,
    this.celebrationSeen = false,
  });

  final String badgeId;
  final DateTime? earnedAt;
  final bool celebrationSeen;

  Map<String, dynamic> toJson() => {
    'badgeId': badgeId,
    'earnedAt': earnedAt?.toUtc().toIso8601String(),
    'celebrationSeen': celebrationSeen,
  };

  factory BadgeProgress.fromJson(Map<String, dynamic> json) => BadgeProgress(
    badgeId: json['badgeId'] as String? ?? '',
    earnedAt: _date(json['earnedAt']),
    celebrationSeen: json['celebrationSeen'] as bool? ?? false,
  );
}

class DailyRewardState {
  const DailyRewardState({
    this.completedDateKey,
    this.pendingRewardId,
    this.claimedItemIds = const [],
    this.placedItemIds = const [],
    this.placementInitialized = false,
  });

  final String? completedDateKey;
  final String? pendingRewardId;
  final List<String> claimedItemIds;
  final List<String> placedItemIds;
  final bool placementInitialized;

  DailyRewardState copyWith({
    String? completedDateKey,
    String? pendingRewardId,
    List<String>? claimedItemIds,
    List<String>? placedItemIds,
    bool? placementInitialized,
    bool clearPendingReward = false,
  }) => DailyRewardState(
    completedDateKey: completedDateKey ?? this.completedDateKey,
    pendingRewardId: clearPendingReward
        ? null
        : pendingRewardId ?? this.pendingRewardId,
    claimedItemIds: claimedItemIds ?? this.claimedItemIds,
    placedItemIds: placedItemIds ?? this.placedItemIds,
    placementInitialized: placementInitialized ?? this.placementInitialized,
  );

  Map<String, dynamic> toJson() => {
    'completedDateKey': completedDateKey,
    'pendingRewardId': pendingRewardId,
    'claimedItemIds': claimedItemIds,
    'placedItemIds': placedItemIds,
  };

  factory DailyRewardState.fromJson(Map<String, dynamic> json) =>
      DailyRewardState(
        completedDateKey: json['completedDateKey'] as String?,
        pendingRewardId: json['pendingRewardId'] as String?,
        claimedItemIds: _stringList(json['claimedItemIds']),
        placedItemIds: _stringList(json['placedItemIds']),
        placementInitialized: json.containsKey('placedItemIds'),
      );
}

class TimerSnapshot {
  const TimerSnapshot({
    this.status = 'idle',
    this.sessionKind = 'focus',
    this.remainingSeconds = 25 * 60,
    this.activeSessionMinutes = 25,
    this.endEpochMs,
    this.sessionId,
    this.activeRitualId,
    this.sessionBreakMinutes,
    this.ritualAudioActive = false,
  });

  final String status;
  final String sessionKind;
  final int remainingSeconds;
  final int activeSessionMinutes;
  final int? endEpochMs;
  final String? sessionId;
  final String? activeRitualId;
  final int? sessionBreakMinutes;
  final bool ritualAudioActive;

  Map<String, dynamic> toJson() => {
    'status': status,
    'sessionKind': sessionKind,
    'remainingSeconds': remainingSeconds,
    'activeSessionMinutes': activeSessionMinutes,
    'endEpochMs': endEpochMs,
    'sessionId': sessionId,
    'activeRitualId': activeRitualId,
    'sessionBreakMinutes': sessionBreakMinutes,
    'ritualAudioActive': ritualAudioActive,
  };

  factory TimerSnapshot.fromJson(Map<String, dynamic> json) => TimerSnapshot(
    status: json['status'] as String? ?? 'idle',
    sessionKind: json['sessionKind'] as String? ?? 'focus',
    remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 25 * 60,
    activeSessionMinutes: (json['activeSessionMinutes'] as num?)?.toInt() ?? 25,
    endEpochMs: (json['endEpochMs'] as num?)?.toInt(),
    sessionId: json['sessionId'] as String?,
    activeRitualId: json['activeRitualId'] as String?,
    sessionBreakMinutes: (json['sessionBreakMinutes'] as num?)?.toInt(),
    ritualAudioActive: json['ritualAudioActive'] as bool? ?? false,
  );
}

class AppProgressV2 {
  const AppProgressV2({
    this.username = 'Selin',
    this.profileAvatarId = 'moonleaf',
    this.darkMode = true,
    this.focusReminders = true,
    this.autoStartBreaks = false,
    this.testMode = false,
    this.dailyGoalMinutes = 120,
    this.defaultFocusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.sleepTimerMinutes = 30,
    this.dailyMinutes = const {},
    this.selectedDecorationIds = const [],
    this.decorationPositions = const {},
    this.soundVolumes = const {},
    this.timer = const TimerSnapshot(),
    this.craftProgress = const CraftProgress(),
    this.inventory = const {},
    this.pendingRewards = const [],
    this.roomPlacements = const {},
    this.badges = const {},
    this.dailyReward = const DailyRewardState(),
    this.focusRituals = const FocusRitualCollection(),
  });

  static const schemaVersion = 4;

  final String username;
  final String profileAvatarId;
  final bool darkMode;
  final bool focusReminders;
  final bool autoStartBreaks;
  final bool testMode;
  final int dailyGoalMinutes;
  final int defaultFocusMinutes;
  final int shortBreakMinutes;
  final int sleepTimerMinutes;
  final Map<String, int> dailyMinutes;
  final List<String> selectedDecorationIds;
  final Map<String, NormalizedPosition> decorationPositions;
  final Map<String, double> soundVolumes;
  final TimerSnapshot timer;
  final CraftProgress craftProgress;
  final Map<String, InventoryEntry> inventory;
  final List<PendingReward> pendingRewards;
  final Map<String, RoomPlacement> roomPlacements;
  final Map<String, BadgeProgress> badges;
  final DailyRewardState dailyReward;
  final FocusRitualCollection focusRituals;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'username': username,
    'profileAvatarId': profileAvatarId,
    'settings': {
      'darkMode': darkMode,
      'focusReminders': focusReminders,
      'autoStartBreaks': autoStartBreaks,
      'testMode': testMode,
      'dailyGoalMinutes': dailyGoalMinutes,
      'defaultFocusMinutes': defaultFocusMinutes,
      'shortBreakMinutes': shortBreakMinutes,
      'sleepTimerMinutes': sleepTimerMinutes,
    },
    'dailyMinutes': dailyMinutes,
    'selectedDecorationIds': selectedDecorationIds,
    'decorationPositions': decorationPositions.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'soundVolumes': soundVolumes,
    'timer': timer.toJson(),
    'craftProgress': craftProgress.toJson(),
    'inventory': inventory.map((key, value) => MapEntry(key, value.toJson())),
    'pendingRewards': pendingRewards.map((value) => value.toJson()).toList(),
    'roomPlacements': roomPlacements.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'badges': badges.map((key, value) => MapEntry(key, value.toJson())),
    'dailyReward': dailyReward.toJson(),
    'focusRituals': focusRituals.toJson(),
  };

  factory AppProgressV2.fromJson(Map<String, dynamic> json) {
    final version = (json['schemaVersion'] as num?)?.toInt();
    if (version != 2 && version != 3 && version != schemaVersion) {
      throw FormatException('Unsupported progress schema: $version');
    }
    final settings = _stringMap(json['settings']);
    return AppProgressV2(
      username: json['username'] as String? ?? 'Selin',
      profileAvatarId: json['profileAvatarId'] as String? ?? 'moonleaf',
      darkMode: settings['darkMode'] as bool? ?? true,
      focusReminders: settings['focusReminders'] as bool? ?? true,
      autoStartBreaks: settings['autoStartBreaks'] as bool? ?? false,
      testMode: settings['testMode'] as bool? ?? false,
      dailyGoalMinutes: (settings['dailyGoalMinutes'] as num?)?.toInt() ?? 120,
      defaultFocusMinutes:
          (settings['defaultFocusMinutes'] as num?)?.toInt() ?? 25,
      shortBreakMinutes: (settings['shortBreakMinutes'] as num?)?.toInt() ?? 5,
      sleepTimerMinutes: (settings['sleepTimerMinutes'] as num?)?.toInt() ?? 30,
      dailyMinutes: _stringIntMap(json['dailyMinutes']),
      selectedDecorationIds: _stringList(json['selectedDecorationIds']),
      decorationPositions: _typedMap(
        json['decorationPositions'],
        NormalizedPosition.fromJson,
      ),
      soundVolumes: _stringDoubleMap(json['soundVolumes']),
      timer: TimerSnapshot.fromJson(_stringMap(json['timer'])),
      craftProgress: CraftProgress.fromJson(_stringMap(json['craftProgress'])),
      inventory: _typedMap(json['inventory'], InventoryEntry.fromJson),
      pendingRewards: _mapList(json['pendingRewards'], PendingReward.fromJson),
      roomPlacements: _typedMap(json['roomPlacements'], RoomPlacement.fromJson),
      badges: _typedMap(json['badges'], BadgeProgress.fromJson),
      dailyReward: DailyRewardState.fromJson(_stringMap(json['dailyReward'])),
      focusRituals: json['focusRituals'] is Map
          ? FocusRitualCollection.fromJson(_stringMap(json['focusRituals']))
          : const FocusRitualCollection(),
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

Map<String, dynamic> _stringMap(Object? value) => value is Map
    ? value.map((key, item) => MapEntry(key.toString(), item))
    : <String, dynamic>{};

List<String> _stringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : <String>[];

Map<String, int> _stringIntMap(Object? value) => _stringMap(
  value,
).map((key, item) => MapEntry(key, (item as num?)?.toInt() ?? 0));

Map<String, double> _stringDoubleMap(Object? value) => _stringMap(
  value,
).map((key, item) => MapEntry(key, (item as num?)?.toDouble() ?? 0));

Map<String, T> _typedMap<T>(
  Object? value,
  T Function(Map<String, dynamic>) fromJson,
) => _stringMap(
  value,
).map((key, item) => MapEntry(key, fromJson(_stringMap(item))));

List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) fromJson) =>
    value is List
    ? value.map((item) => fromJson(_stringMap(item))).toList()
    : <T>[];
