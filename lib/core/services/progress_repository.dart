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
      if (placed) {
        final canonical = NormalizedPosition(
          item.placement.position.dx,
          item.placement.position.dy,
        );
        migratedPositions[item.id] = canonical;
        roomPlacements[item.id] = RoomPlacement(
          itemId: item.id,
          slotId: item.placement.slotId,
          layer: item.placement.layer.index,
          position: canonical,
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
}
