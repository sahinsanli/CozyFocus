import 'package:cozy_focus/app.dart';
import 'package:cozy_focus/core/assets/app_assets.dart';
import 'package:cozy_focus/core/models/decoration_item.dart';
import 'package:cozy_focus/core/services/app_controller.dart';
import 'package:cozy_focus/core/services/progress_repository.dart';
import 'package:cozy_focus/core/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch shows splash and completes all onboarding pages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    var completed = false;

    await tester.pumpWidget(
      CozyFocusApp(
        controller: controller,
        showLaunchExperience: true,
        onboardingCompleted: false,
        onOnboardingComplete: () async => completed = true,
      ),
    );
    await tester.pump();

    expect(find.text('Cozy Focus\nRoom'), findsOneWidget);
    expect(find.text('Your peaceful space to grow.'), findsOneWidget);
    final illustrationSize = tester.getSize(
      find.byKey(const Key('splash-illustration')),
    );
    final illustrationCenter = tester.getCenter(
      find.byKey(const Key('splash-illustration')),
    );
    expect(
      illustrationSize.width / illustrationSize.height,
      closeTo(900 / 1748, .01),
    );
    expect(illustrationCenter.dx, closeTo(201, .01));
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('splash-begin')));
    await tester.pumpAndSettle();
    expect(find.text('Find Your Focus'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.text('Watch Your Progress Grow'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.text('Your Personal Sanctuary'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.text('Set Your Focus Rhythm'), findsOneWidget);
    expect(find.text('Save & Start'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-daily-goal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preference-option-360')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-focus-duration')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preference-option-75')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-break-duration')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preference-option-15')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(controller.dailyGoalMinutes, 360);
    expect(controller.defaultFocusMinutes, 75);
    expect(controller.shortBreakMinutes, 15);
    expect(find.text('Ready to focus?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding can be skipped without changing preferences', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    var completed = false;

    await tester.pumpWidget(
      CozyFocusApp(
        controller: controller,
        showLaunchExperience: true,
        onboardingCompleted: false,
        onOnboardingComplete: () async => completed = true,
      ),
    );
    await tester.tap(find.byKey(const Key('splash-begin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(controller.dailyGoalMinutes, 120);
    expect(controller.defaultFocusMinutes, 25);
    expect(controller.shortBreakMinutes, 5);
    expect(find.text('Ready to focus?'), findsOneWidget);
  });

  testWidgets('Turkish preference page fits a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setLanguageCode('tr');

    await tester.pumpWidget(
      CozyFocusApp(
        controller: controller,
        showLaunchExperience: true,
        onboardingCompleted: false,
      ),
    );
    await tester.tap(find.byKey(const Key('splash-begin')));
    await tester.pumpAndSettle();
    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Odak Ritmini Ayarla'), findsOneWidget);
    expect(find.text('Kaydet ve Başla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returning users leave the splash directly for the home screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(
      CozyFocusApp(
        controller: controller,
        showLaunchExperience: true,
        onboardingCompleted: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('splash-begin')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Ready to focus?'), findsOneWidget);
    expect(find.text('Find Your Focus'), findsNothing);
  });

  testWidgets('main navigation retains all four core destinations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Ready to focus?'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Room'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Sounds'), findsOneWidget);

    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();
    expect(find.text('Room Decoration'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your Journey'), findsOneWidget);
    expect(find.text('Sleeping Cat'), findsOneWidget);
    expect(find.text('Study Chair'), findsOneWidget);

    await tester.tap(find.text('Sounds'));
    await tester.pumpAndSettle();
    expect(find.text('Rainy Night'), findsOneWidget);
  });

  testWidgets('guest focus prompt opens the account and sync screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    final prompt = find.byKey(const Key('focus-account-prompt'));
    expect(prompt, findsOneWidget);
    await tester.ensureVisible(prompt);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('focus-open-account')));
    await tester.pumpAndSettle();

    expect(find.text('Account & Sync'), findsOneWidget);
    expect(find.text('Keep your progress safe'), findsOneWidget);
    expect(
      find.textContaining('Account services are temporarily unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('profile and settings are reachable from the app bar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Customize your cozy experience.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-button')));
    await tester.pumpAndSettle();
    expect(find.text('Earned Badges'), findsOneWidget);
    expect(find.text('First Bloom'), findsOneWidget);
    expect(find.text('Zen Keeper'), findsOneWidget);
  });

  testWidgets('test mode accelerates and saves normal focus progress', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setDefaultFocusMinutes(15);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Test Mode'), findsOneWidget);

    await tester.ensureVisible(find.text('Advance 5 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advance 5 min'));
    await tester.pumpAndSettle();
    expect(controller.testElapsedMinutes, 5);
    expect(find.text('TEST PREVIEW'), findsOneWidget);

    await tester.ensureVisible(find.text('Complete focus now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete focus now'));
    await tester.pumpAndSettle();
    expect(find.text('Test session complete'), findsOneWidget);
    expect(controller.allTimeMinutes, 15);
    expect(controller.craftProgress.accumulatedMinutes, 15);
  });

  testWidgets('editing the profile name saves without a framework error', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sahin');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.username, 'Sahin');
    final savedProgress = await SharedPreferencesProgressRepository(
      preferences,
    ).load();
    expect(savedProgress.username, 'Sahin');
    expect(find.text('Sahin'), findsOneWidget);
  });

  testWidgets('profile picture picker updates the shared avatar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-avatar-edit')));
    await tester.pumpAndSettle();

    expect(find.text('Choose your profile picture'), findsOneWidget);
    await tester.tap(find.text('Sleepy Cat'));
    await tester.pumpAndSettle();

    expect(controller.profileAvatarId, 'cat');
    final saved = await SharedPreferencesProgressRepository(preferences).load();
    expect(saved.profileAvatarId, 'cat');
    expect(tester.takeException(), isNull);
  });

  testWidgets('core screens do not overflow on a narrow phone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final destination in ['Room', 'Stats', 'Sounds']) {
      await tester.tap(find.text(destination));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('clean install stays English on a Turkish device locale', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('tr');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.restore();

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Ready to focus?'), findsOneWidget);
    expect(find.text('Odaklanmaya hazır mısın?'), findsNothing);
  });

  testWidgets(
    'Turkish applies instantly, survives restore, and keeps sound names English',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);
      await tester.pumpWidget(CozyFocusApp(controller: controller));
      await tester.pumpAndSettle();

      await controller.setLanguageCode('tr');
      await tester.pumpAndSettle();
      expect(find.text('Odaklanmaya hazır mısın?'), findsOneWidget);
      expect(find.text('Odak'), findsOneWidget);
      expect(find.text('Oda'), findsOneWidget);

      await tester.tap(find.text('Sesler'));
      await tester.pumpAndSettle();
      expect(find.text('Ortam\nSesleri'), findsOneWidget);
      expect(find.text('Rainy Night'), findsOneWidget);
      expect(find.text('Soft Piano'), findsOneWidget);

      final restored = AppController(preferences);
      await restored.restore();
      expect(restored.languageCode, 'tr');
    },
  );

  testWidgets(
    'Turkish settings expose 8 hour goal and 90 minute focus without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final controller = AppController(preferences);
      await controller.setLanguageCode('tr');
      await controller.setDailyGoal(480);
      await controller.setDefaultFocusMinutes(90);

      await tester.pumpWidget(CozyFocusApp(controller: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ayarlar'));
      await tester.pumpAndSettle();

      expect(find.text('8 sa'), findsOneWidget);
      expect(find.text('1 sa 30 dk'), findsOneWidget);
      expect(find.text('Dil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('room decorations stay in their exclusive canonical homes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.recordCompletedSession(30);
    await controller.claimNextReward(place: true);
    await controller.markBadgeCelebrationSeen('first_focus');
    await controller.markBadgeCelebrationSeen('first_claim');
    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();

    final desk = find.byKey(const Key('room-decoration-desk'));
    expect(desk, findsOneWidget);
    await tester.ensureVisible(desk);
    await tester.pumpAndSettle();
    final canonical = decorationCatalog.first.placement.position;
    final gesture = await tester.startGesture(tester.getCenter(desk));
    await gesture.moveBy(const Offset(240, 180));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.decorationPositions['desk'], canonical);
    expect(controller.roomPlacements['desk']?.slotId, 'desk_home');
    expect(tester.takeException(), isNull);
  });

  testWidgets('gentle goal collection paints every configured reward preview', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gentle Goal Collection'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    for (final item in dailyDecorationCatalog) {
      expect(find.byKey(Key('gentle-goal-${item.id}')), findsOneWidget);
    }
    expect(find.text('Mystery'), findsNWidgets(dailyDecorationCatalog.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed room renders every fixed decoration in one scene', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await controller.setDailyGoal(30);
    final firstDay = DateTime(2026, 8, 1);
    for (var day = 0; day < dailyDecorationCatalog.length; day++) {
      await controller.recordCompletedSession(
        day == 0 ? 2200 : 30,
        on: firstDay.add(Duration(days: day)),
      );
      while (controller.nextPendingReward != null) {
        await controller.claimNextReward(place: true);
      }
    }
    for (final badgeId in controller.badgeProgress.keys.toList()) {
      await controller.markBadgeCelebrationSeen(badgeId);
    }

    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Room Decoration').evaluate().isEmpty) {
      await tester.tap(find.text('Room'));
      await tester.pumpAndSettle();
    }

    final roomContext = tester.element(find.byKey(const Key('room-canvas')));
    await tester.runAsync(() async {
      await Future.wait([
        precacheImage(const AssetImage(AppAssets.emptyRoomBaseV2), roomContext),
        precacheImage(const AssetImage(AppAssets.mainItemAtlasV2), roomContext),
        precacheImage(
          const AssetImage(AppAssets.rewardAvatarAtlasV2),
          roomContext,
        ),
      ]);
    });
    await tester.pumpAndSettle();

    for (final item in decorationCatalog) {
      expect(find.byKey(Key('room-decoration-${item.id}')), findsOneWidget);
    }
    for (final item in dailyDecorationCatalog) {
      expect(find.byKey(Key('room-collectible-${item.id}')), findsOneWidget);
    }
    final roomRect = tester.getRect(find.byKey(const Key('room-canvas')));
    expect(roomRect.width, greaterThan(300));
    expect(roomRect.height, greaterThan(roomRect.width));
    await expectLater(
      find.byKey(const Key('room-canvas')),
      matchesGoldenFile('goldens/completed_room.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('active sound previews animate without framework errors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sounds'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Play Rainy Night'));
    await tester.pump(const Duration(seconds: 1));

    expect(controller.soundVolumes['rain'], greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('only bundled sounds are enabled in the production mixer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(
      preferences,
      audioService: AssetAudioService(),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sounds'));
    await tester.pumpAndSettle();

    expect(find.text('COMING SOON'), findsNWidgets(2));
    expect(controller.isSoundAvailable('rain'), isTrue);
    expect(controller.isSoundAvailable('fire'), isTrue);
    expect(controller.isSoundAvailable('forest'), isTrue);
    expect(controller.isSoundAvailable('piano'), isTrue);
    expect(controller.isSoundAvailable('pond'), isFalse);
  });
}
