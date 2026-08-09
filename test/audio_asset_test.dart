import 'dart:io';

import 'package:cozy_focus/core/assets/app_assets.dart';
import 'package:cozy_focus/core/models/sound_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every available ambience has a bundled non-empty audio file', () {
    final available = soundCatalog.where((sound) => sound.isAvailable);
    expect(
      available.map((sound) => sound.id).toSet(),
      AppAssets.audioById.keys.toSet(),
    );
    for (final sound in available) {
      final file = File(sound.audioAsset!);
      expect(file.existsSync(), isTrue, reason: sound.id);
      expect(file.lengthSync(), greaterThan(4096), reason: sound.id);
    }
  });

  test('every interaction effect has a bundled non-empty audio file', () {
    for (final path in const [
      AppAssets.clickAudio,
      AppAssets.woodCutAudio,
      AppAssets.puttingItemAudio,
      AppAssets.claimRewardAudio,
      AppAssets.catMeowAudio,
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      expect(file.lengthSync(), greaterThan(4096), reason: path);
    }
  });
}
