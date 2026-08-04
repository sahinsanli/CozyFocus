import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/decoration_item.dart';
import '../models/sound_item.dart';
import 'audio_service.dart';

enum FocusTimerStatus { idle, running, paused, complete }

class AppController extends ChangeNotifier {
  AppController(this._preferences, {AudioService? audioService})
    : _audioService = audioService ?? MockAudioService();

  final SharedPreferences _preferences;
  final AudioService _audioService;
  Timer? _ticker;

  String username = 'Selin';
  bool darkMode = false;
  bool focusReminders = true;
  bool autoStartBreaks = false;
  int dailyGoalMinutes = 120;
  int defaultFocusMinutes = 25;
  int shortBreakMinutes = 5;

  FocusTimerStatus timerStatus = FocusTimerStatus.idle;
  int remainingSeconds = 25 * 60;
  int activeSessionMinutes = 25;
  bool showCelebration = false;
  int lastRewardMinutes = 0;

  final Map<String, int> _dailyMinutes = {};
  final Set<String> selectedDecorationIds = {'cactus', 'bookshelf'};
  bool layoutSaved = false;

  final Map<String, double> soundVolumes = {
    for (final sound in soundCatalog) sound.id: 0,
  };
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

  int get unlockedDecorationCount => decorationCatalog
      .where((item) => allTimeMinutes >= item.unlockMinutes)
      .length;

  double get timerProgress {
    final total = activeSessionMinutes * 60;
    if (total == 0) return 0;
    return (1 - remainingSeconds / total).clamp(0, 1);
  }

  Future<void> restore() async {
    username = _preferences.getString('username') ?? username;
    darkMode = _preferences.getBool('darkMode') ?? darkMode;
    focusReminders = _preferences.getBool('focusReminders') ?? focusReminders;
    autoStartBreaks =
        _preferences.getBool('autoStartBreaks') ?? autoStartBreaks;
    dailyGoalMinutes =
        _preferences.getInt('dailyGoalMinutes') ?? dailyGoalMinutes;
    defaultFocusMinutes =
        _preferences.getInt('defaultFocusMinutes') ?? defaultFocusMinutes;
    shortBreakMinutes =
        _preferences.getInt('shortBreakMinutes') ?? shortBreakMinutes;
    activeSessionMinutes =
        _preferences.getInt('activeSessionMinutes') ?? defaultFocusMinutes;
    remainingSeconds =
        _preferences.getInt('remainingSeconds') ?? defaultFocusMinutes * 60;

    final dailyJson = _preferences.getString('dailyMinutes');
    if (dailyJson != null) {
      final values = jsonDecode(dailyJson) as Map<String, dynamic>;
      _dailyMinutes.addAll(
        values.map((key, value) => MapEntry(key, value as int)),
      );
    }

    selectedDecorationIds
      ..clear()
      ..addAll(
        _preferences.getStringList('selectedDecorations') ??
            const ['cactus', 'bookshelf'],
      );

    for (final sound in soundCatalog) {
      soundVolumes[sound.id] =
          _preferences.getDouble('volume_${sound.id}') ?? 0;
    }
    sleepTimerMinutes =
        _preferences.getInt('sleepTimerMinutes') ?? sleepTimerMinutes;

    final savedStatus = _preferences.getString('timerStatus');
    if (savedStatus == FocusTimerStatus.running.name) {
      final end = _preferences.getInt('timerEndEpochMs');
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
    await _persistTimer();
    notifyListeners();
  }

  void dismissCelebration() {
    showCelebration = false;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        _ticker?.cancel();
        await _completeSession();
      } else {
        remainingSeconds--;
        notifyListeners();
      }
    });
  }

  Future<void> _completeSession() async {
    _ticker?.cancel();
    final minutes = activeSessionMinutes;
    final key = _dateKey(DateTime.now());
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    timerStatus = FocusTimerStatus.complete;
    remainingSeconds = 0;
    lastRewardMinutes = minutes;
    showCelebration = true;
    await _preferences.setString('dailyMinutes', jsonEncode(_dailyMinutes));
    await _persistTimer();
    notifyListeners();
  }

  @visibleForTesting
  Future<void> recordCompletedSession(int minutes, {DateTime? on}) async {
    final key = _dateKey(on ?? DateTime.now());
    _dailyMinutes[key] = (_dailyMinutes[key] ?? 0) + minutes;
    await _preferences.setString('dailyMinutes', jsonEncode(_dailyMinutes));
    notifyListeners();
  }

  Future<void> _persistTimer() async {
    await _preferences.setString('timerStatus', timerStatus.name);
    await _preferences.setInt('remainingSeconds', remainingSeconds);
    await _preferences.setInt('activeSessionMinutes', activeSessionMinutes);
    if (timerStatus == FocusTimerStatus.running) {
      await _preferences.setInt(
        'timerEndEpochMs',
        DateTime.now()
            .add(Duration(seconds: remainingSeconds))
            .millisecondsSinceEpoch,
      );
    } else {
      await _preferences.remove('timerEndEpochMs');
    }
  }

  Future<void> toggleDecoration(String id) async {
    final item = decorationCatalog.firstWhere((item) => item.id == id);
    if (allTimeMinutes < item.unlockMinutes) return;
    layoutSaved = false;
    if (!selectedDecorationIds.remove(id)) selectedDecorationIds.add(id);
    notifyListeners();
  }

  Future<void> saveLayout() async {
    await _preferences.setStringList(
      'selectedDecorations',
      selectedDecorationIds.toList(),
    );
    layoutSaved = true;
    notifyListeners();
  }

  Future<void> toggleSound(String id) async {
    final current = soundVolumes[id] ?? 0;
    if (current > 0) {
      soundVolumes[id] = 0;
      await _audioService.pause(id);
    } else {
      soundVolumes[id] = .6;
      await _audioService.play(id, .6);
    }
    await _preferences.setDouble('volume_$id', soundVolumes[id]!);
    notifyListeners();
  }

  Future<void> setSoundVolume(String id, double value) async {
    soundVolumes[id] = value;
    if (value == 0) {
      await _audioService.pause(id);
    } else {
      await _audioService.setVolume(id, value);
    }
    await _preferences.setDouble('volume_$id', value);
    notifyListeners();
  }

  Future<void> stopAllSounds() async {
    for (final id in soundVolumes.keys) {
      soundVolumes[id] = 0;
      await _preferences.setDouble('volume_$id', 0);
    }
    await _audioService.stopAll();
    notifyListeners();
  }

  Future<void> setSleepTimer(int minutes) async {
    sleepTimerMinutes = minutes;
    await _preferences.setInt('sleepTimerMinutes', minutes);
    notifyListeners();
  }

  Future<void> setUsername(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    username = trimmed;
    await _preferences.setString('username', trimmed);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _preferences.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setFocusReminders(bool value) async {
    focusReminders = value;
    await _preferences.setBool('focusReminders', value);
    notifyListeners();
  }

  Future<void> setAutoStartBreaks(bool value) async {
    autoStartBreaks = value;
    await _preferences.setBool('autoStartBreaks', value);
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    dailyGoalMinutes = value;
    await _preferences.setInt('dailyGoalMinutes', value);
    notifyListeners();
  }

  Future<void> setDefaultFocusMinutes(int value) async {
    defaultFocusMinutes = value;
    await _preferences.setInt('defaultFocusMinutes', value);
    if (timerStatus == FocusTimerStatus.idle) {
      activeSessionMinutes = value;
      remainingSeconds = value * 60;
      await _persistTimer();
    }
    notifyListeners();
  }

  Future<void> setShortBreakMinutes(int value) async {
    shortBreakMinutes = value;
    await _preferences.setInt('shortBreakMinutes', value);
    notifyListeners();
  }

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

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
