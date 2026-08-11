import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/app_audio_session.dart';
import 'core/services/app_controller.dart';
import 'core/services/account_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/sound_effect_service.dart';
import 'core/services/firebase_progress_repository.dart';
import 'core/services/progress_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppAudioSession.configure();
  final preferences = await SharedPreferences.getInstance();
  final freshDebugStart = await prepareFreshDebugStart(preferences);
  ProgressRepository progressRepository = SharedPreferencesProgressRepository(
    preferences,
  );
  AccountService? accountService;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
    } catch (error, stackTrace) {
      debugPrint('App Check startup failed; Firebase remains active: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    final firebaseAccountService = FirebaseAccountService();
    if (freshDebugStart) {
      await firebaseAccountService.signOutToGuest();
    } else {
      await firebaseAccountService.ensureGuest();
    }
    accountService = firebaseAccountService;
    progressRepository = FirebaseProgressRepository(preferences: preferences);
  } catch (error, stackTrace) {
    debugPrint('Firebase startup failed; using local progress: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  final controller = AppController(
    preferences,
    audioService: AssetAudioService(),
    soundEffectService: AssetSoundEffectService(),
    progressRepository: progressRepository,
    accountService: accountService,
  );
  await controller.restore();
  const onboardingStorageKey = 'onboarding_complete_v1';
  runApp(
    CozyFocusApp(
      controller: controller,
      showLaunchExperience: true,
      onboardingCompleted: preferences.getBool(onboardingStorageKey) ?? false,
      onOnboardingComplete: () async {
        await preferences.setBool(onboardingStorageKey, true);
      },
    ),
  );
}

const debugFreshStartStorageKey = 'debug_fresh_start_2026_08_11_v1';

/// Clears old local test progress once in debug builds so the next full app
/// restart behaves like a clean installation. Release users are never reset.
@visibleForTesting
Future<bool> prepareFreshDebugStart(
  SharedPreferences preferences, {
  bool enabled = kDebugMode,
}) async {
  if (!enabled || (preferences.getBool(debugFreshStartStorageKey) ?? false)) {
    return false;
  }
  await preferences.clear();
  await preferences.setBool(debugFreshStartStorageKey, true);
  return true;
}
