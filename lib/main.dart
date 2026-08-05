import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/app_controller.dart';
import 'core/services/audio_service.dart';
import 'core/services/sound_effect_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final controller = AppController(
    preferences,
    audioService: AssetAudioService(),
    soundEffectService: AssetSoundEffectService(),
  );
  await controller.restore();
  runApp(CozyFocusApp(controller: controller));
}
