import 'package:cozy_focus/app.dart';
import 'package:cozy_focus/core/services/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    await tester.tap(find.text('Sounds'));
    await tester.pumpAndSettle();
    expect(find.text('Rainy Night'), findsOneWidget);
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
    expect(preferences.getString('username'), 'Sahin');
    expect(find.text('Sahin'), findsOneWidget);
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

  testWidgets('Moonleaf animates and room decorations can be dragged', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController(preferences);
    await tester.pumpWidget(CozyFocusApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();

    final plant = find.byKey(const Key('room-decoration-cactus'));
    expect(plant, findsOneWidget);
    await tester.ensureVisible(plant);
    await tester.pumpAndSettle();
    await tester.tap(plant);
    await tester.pump(const Duration(milliseconds: 800));
    final gesture = await tester.startGesture(tester.getCenter(plant));
    await gesture.moveBy(const Offset(22, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(22, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(22, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(22, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.decorationPositions['cactus']!.dx, greaterThan(.1));
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
}
