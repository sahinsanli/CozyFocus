import 'dart:io';
import 'dart:ui' as ui;

import 'package:cozy_focus/core/assets/app_assets.dart';
import 'package:cozy_focus/core/models/decoration_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('room v2 catalogs contain every planned visual asset', () {
    expect(decorationCatalog, hasLength(10));
    expect(dailyDecorationCatalog, hasLength(8));
    expect(profileAvatarCatalog, hasLength(6));
    expect(
      decorationCatalog.map((item) => item.id).toSet(),
      hasLength(decorationCatalog.length),
    );
    expect(
      decorationCatalog.map((item) => item.craftAtlasRow),
      everyElement(greaterThanOrEqualTo(0)),
    );
    expect(
      decorationCatalog.map((item) => item.defaultSlotId),
      everyElement(isNotEmpty),
    );
  });

  test('generated sprite atlases have transparent corners', () async {
    for (final path in const [
      AppAssets.mainItemAtlasV2,
      AppAssets.rewardAvatarAtlasV2,
      AppAssets.craftingAtlasAV2,
      AppAssets.craftingAtlasBV2,
      AppAssets.craftingAtlasCV2,
    ]) {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final pixels = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      expect(pixels, isNotNull, reason: path);
      expect(pixels!.getUint8(3), 0, reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });

  test(
    'empty room background exists at portrait production resolution',
    () async {
      final bytes = await File(AppAssets.emptyRoomBaseV2).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      expect(frame.image.width, 899);
      expect(frame.image.height, 1748);

      frame.image.dispose();
      codec.dispose();
    },
  );
}
