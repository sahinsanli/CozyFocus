import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_progress.dart';
import '../models/decoration_item.dart';
import '../models/sound_item.dart';

abstract interface class ProgressRepository {
  Future<AppProgressV2> load();
  Future<void> save(AppProgressV2 progress);
}

class SharedPreferencesProgressRepository implements ProgressRepository {
  SharedPreferencesProgressRepository(this._preferences);

  static const storageKey = 'app_progress_v2';
  static const corruptBackupPrefix = 'app_progress_v2_corrupt_';

  final SharedPreferences _preferences;

  @override
  Future<AppProgressV2> load() async {
    final stored = _preferences.getString(storageKey);
    if (stored != null) {
      try {
        return AppProgressV2.fromJson(
          jsonDecode(stored) as Map<String, dynamic>,
        );
      } catch (_) {
        await _preferences.setString(
          '$corruptBackupPrefix${DateTime.now().millisecondsSinceEpoch}',
          stored,
        );
      }
    }

    final migrated = _migrateLegacy();
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(AppProgressV2 progress) async {
    await _preferences.setString(storageKey, jsonEncode(progress.toJson()));
  }

  AppProgressV2 _migrateLegacy() {
    final defaultFocusMinutes =
        _preferences.getInt('defaultFocusMinutes') ?? 25;
    final dailyMinutes = _decodeDailyMinutes(
      _preferences.getString('dailyMinutes'),
    );
    final allTimeMinutes = dailyMinutes.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final selected =
        (_preferences.getStringList('selectedDecorations') ?? const <String>[])
            .map(_currentDecorationId)
            .toSet()
            .toList();
    final positions = _decodePositions(
      _preferences.getString('decorationPositions'),
    );
    final inventory = <String, InventoryEntry>{};
    final roomPlacements = <String, RoomPlacement>{};
    final migratedPositions = Map<String, NormalizedPosition>.of(positions);

    for (final item in decorationCatalog) {
      final placed = selected.contains(item.id);
      final unlocked = placed || allTimeMinutes >= item.unlockMinutes;
      inventory[item.id] = InventoryEntry(
        itemId: item.id,
        status: !unlocked
            ? InventoryStatus.locked
            : placed
            ? InventoryStatus.placed
            : InventoryStatus.owned,
      );
      final position = positions[item.id];
      if (placed) {
        final snapped = _nearestSlot(
          item.slotType,
          position ??
              NormalizedPosition(
                item.defaultPosition.dx,
                item.defaultPosition.dy,
              ),
        );
        migratedPositions[item.id] = snapped.$2;
        roomPlacements[item.id] = RoomPlacement(
          itemId: item.id,
          slotId: snapped.$1,
          layer: item.layer.index,
          position: snapped.$2,
          interactionEnabled: false,
        );
      }
    }

    final badges = <String, BadgeProgress>{
      for (final entry in const {
        'first_bloom': 25,
        'night_owl': 120,
        'deep_woods': 300,
        'zen_keeper': 600,
      }.entries)
        entry.key: BadgeProgress(
          badgeId: entry.key,
          earnedAt: allTimeMinutes >= entry.value ? DateTime.now() : null,
          celebrationSeen: allTimeMinutes >= entry.value,
        ),
    };

    return AppProgressV2(
      username: _preferences.getString('username') ?? 'Selin',
      darkMode: _preferences.getBool('darkMode') ?? false,
      focusReminders: _preferences.getBool('focusReminders') ?? true,
      autoStartBreaks: _preferences.getBool('autoStartBreaks') ?? false,
      testMode: _preferences.getBool('testMode') ?? true,
      dailyGoalMinutes: _preferences.getInt('dailyGoalMinutes') ?? 120,
      defaultFocusMinutes: defaultFocusMinutes,
      shortBreakMinutes: _preferences.getInt('shortBreakMinutes') ?? 5,
      sleepTimerMinutes: _preferences.getInt('sleepTimerMinutes') ?? 30,
      dailyMinutes: dailyMinutes,
      selectedDecorationIds: selected,
      decorationPositions: migratedPositions,
      soundVolumes: {
        for (final sound in soundCatalog)
          sound.id: _preferences.getDouble('volume_${sound.id}') ?? 0,
      },
      timer: TimerSnapshot(
        status: _preferences.getString('timerStatus') ?? 'idle',
        remainingSeconds:
            _preferences.getInt('remainingSeconds') ?? defaultFocusMinutes * 60,
        activeSessionMinutes:
            _preferences.getInt('activeSessionMinutes') ?? defaultFocusMinutes,
        endEpochMs: _preferences.getInt('timerEndEpochMs'),
      ),
      inventory: inventory,
      roomPlacements: roomPlacements,
      badges: badges,
    );
  }

  Map<String, int> _decodeDailyMinutes(String? source) {
    if (source == null) return {};
    try {
      final values = jsonDecode(source) as Map<String, dynamic>;
      return values.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Map<String, NormalizedPosition> _decodePositions(String? source) {
    if (source == null) return _defaultPositions;
    try {
      final values = jsonDecode(source) as Map<String, dynamic>;
      return values.map((key, value) {
        final coordinates = value as List<dynamic>;
        return MapEntry(
          _currentDecorationId(key),
          NormalizedPosition(
            (coordinates[0] as num).toDouble(),
            (coordinates[1] as num).toDouble(),
          ),
        );
      });
    } catch (_) {
      return _defaultPositions;
    }
  }

  static final _defaultPositions = <String, NormalizedPosition>{
    for (final item in decorationCatalog)
      item.id: NormalizedPosition(
        item.defaultPosition.dx,
        item.defaultPosition.dy,
      ),
  };

  static String _currentDecorationId(String legacyId) => switch (legacyId) {
    'cactus' => 'potted_plant',
    'armchair' => 'chair',
    _ => legacyId,
  };

  static (String, NormalizedPosition) _nearestSlot(
    RoomSlotType type,
    NormalizedPosition position,
  ) {
    final compatible = _migrationSlots
        .where((slot) => slot.$2 == type)
        .toList();
    compatible.sort((a, b) {
      final aDistance =
          (a.$3.x - position.x) * (a.$3.x - position.x) +
          (a.$3.y - position.y) * (a.$3.y - position.y);
      final bDistance =
          (b.$3.x - position.x) * (b.$3.x - position.x) +
          (b.$3.y - position.y) * (b.$3.y - position.y);
      return aDistance.compareTo(bDistance);
    });
    return (compatible.first.$1, compatible.first.$3);
  }

  static const _migrationSlots = <(String, RoomSlotType, NormalizedPosition)>[
    ('floor_back_left', RoomSlotType.floor, NormalizedPosition(-.34, .04)),
    ('floor_back_right', RoomSlotType.floor, NormalizedPosition(.44, -.02)),
    ('floor_middle_left', RoomSlotType.floor, NormalizedPosition(-.18, .29)),
    ('floor_middle_right', RoomSlotType.floor, NormalizedPosition(.47, .24)),
    ('floor_front_center', RoomSlotType.floor, NormalizedPosition(.02, .62)),
    ('floor_front_right', RoomSlotType.floor, NormalizedPosition(.43, .58)),
    ('wall_left', RoomSlotType.wall, NormalizedPosition(-.38, -.52)),
    ('wall_right', RoomSlotType.wall, NormalizedPosition(.43, -.56)),
    ('ceiling_left', RoomSlotType.ceiling, NormalizedPosition(-.52, -.56)),
    ('ceiling_right', RoomSlotType.ceiling, NormalizedPosition(.62, -.55)),
    ('table_left', RoomSlotType.tabletop, NormalizedPosition(-.42, -.04)),
    ('table_right', RoomSlotType.tabletop, NormalizedPosition(-.07, 0)),
  ];
}
