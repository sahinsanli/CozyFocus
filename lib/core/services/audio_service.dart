import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../assets/app_assets.dart';

abstract interface class AudioService {
  bool supports(String id);
  Future<void> play(String id, double volume);
  Future<void> pause(String id);
  Future<void> setVolume(String id, double volume);
  Future<void> stopAll();
  Future<void> dispose();
}

/// Plays each ambience on its own looping player so multiple sounds can be
/// mixed simultaneously with independent volume controls.
class AssetAudioService implements AudioService {
  AssetAudioService({this.assets = AppAssets.audioById});

  final Map<String, String> assets;
  final Map<String, AudioPlayer> _players = {};
  final Map<String, Future<void>> _loadOperations = {};

  @override
  bool supports(String id) => assets.containsKey(id);

  Future<AudioPlayer> _playerFor(String id) async {
    final assetPath = assets[id];
    if (assetPath == null) {
      throw ArgumentError.value(id, 'id', 'No bundled audio asset');
    }
    final player = _players.putIfAbsent(id, AudioPlayer.new);
    final loadOperation = _loadOperations[id] ??= () async {
      await player.setAsset(assetPath);
      await player.setLoopMode(LoopMode.one);
    }();
    try {
      await loadOperation;
    } catch (_) {
      _loadOperations.remove(id);
      rethrow;
    }
    return player;
  }

  @override
  Future<void> play(String id, double volume) async {
    final player = await _playerFor(id);
    await player.setVolume(volume.clamp(0, 1));
    unawaited(player.play());
  }

  @override
  Future<void> pause(String id) async {
    final player = _players[id];
    if (player != null) await player.pause();
  }

  @override
  Future<void> setVolume(String id, double volume) async {
    final player = await _playerFor(id);
    await player.setVolume(volume.clamp(0, 1));
  }

  @override
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.pause();
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _loadOperations.clear();
  }
}

/// Test-safe implementation that keeps controller state functional without
/// requiring a platform audio plugin.
class MockAudioService implements AudioService {
  @override
  bool supports(String id) => true;

  @override
  Future<void> pause(String id) async {}

  @override
  Future<void> play(String id, double volume) async {}

  @override
  Future<void> setVolume(String id, double volume) async {}

  @override
  Future<void> stopAll() async {}

  @override
  Future<void> dispose() async {}
}
