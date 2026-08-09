import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../assets/app_assets.dart';
import 'app_audio_session.dart';

enum AppSoundEffect { click, woodCut, puttingItem, claimReward, catMeow }

abstract interface class SoundEffectService {
  Future<void> play(AppSoundEffect effect);
  Future<void> dispose();
}

/// Keeps short UI and reward effects separate from the looping ambience
/// players, allowing effects to play without interrupting an active mix.
class AssetSoundEffectService implements SoundEffectService {
  static const _assets = <AppSoundEffect, String>{
    AppSoundEffect.click: AppAssets.clickAudio,
    AppSoundEffect.woodCut: AppAssets.woodCutAudio,
    AppSoundEffect.puttingItem: AppAssets.puttingItemAudio,
    AppSoundEffect.claimReward: AppAssets.claimRewardAudio,
    AppSoundEffect.catMeow: AppAssets.catMeowAudio,
  };

  static const _volumes = <AppSoundEffect, double>{
    AppSoundEffect.click: .24,
    AppSoundEffect.woodCut: .58,
    AppSoundEffect.puttingItem: .58,
    AppSoundEffect.claimReward: .68,
    AppSoundEffect.catMeow: .55,
  };

  final Map<AppSoundEffect, AudioPlayer> _players = {};
  final Map<AppSoundEffect, Future<void>> _loadOperations = {};

  Future<AudioPlayer> _playerFor(AppSoundEffect effect) async {
    final player = _players.putIfAbsent(effect, AudioPlayer.new);
    final loadOperation = _loadOperations[effect] ??= () async {
      await player.setAsset(_assets[effect]!);
      await player.setLoopMode(LoopMode.off);
    }();
    try {
      await loadOperation;
    } catch (_) {
      _loadOperations.remove(effect);
      _players.remove(effect);
      await player.dispose();
      rethrow;
    }
    return player;
  }

  @override
  Future<void> play(AppSoundEffect effect) async {
    await AppAudioSession.activate();
    final player = await _playerFor(effect);
    await player.setVolume(_volumes[effect]!);
    await player.seek(Duration.zero);
    unawaited(player.play());
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

class MockSoundEffectService implements SoundEffectService {
  @override
  Future<void> play(AppSoundEffect effect) async {}

  @override
  Future<void> dispose() async {}
}
