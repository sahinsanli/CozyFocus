import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scope.dart';
import 'core/widgets/tap_sound_region.dart';
import 'features/onboarding/launch_experience.dart';
import 'home_shell.dart';
import 'l10n/app_localizations.dart';

class CozyFocusApp extends StatelessWidget {
  const CozyFocusApp({
    required this.controller,
    this.showLaunchExperience = false,
    this.onboardingCompleted = true,
    this.onOnboardingComplete,
    super.key,
  });

  final AppController controller;
  final bool showLaunchExperience;
  final bool onboardingCompleted;
  final Future<void> Function()? onOnboardingComplete;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: Locale(controller.languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => TapSoundRegion(
            onTap: controller.playTapSound,
            child: child ?? const SizedBox.shrink(),
          ),
          home: showLaunchExperience
              ? LaunchExperience(
                  onboardingCompleted: onboardingCompleted,
                  onOnboardingComplete: onOnboardingComplete ?? () async {},
                )
              : const HomeShell(),
        ),
      ),
    );
  }
}
