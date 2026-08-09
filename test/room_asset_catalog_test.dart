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
    expect(
      decorationCatalog.map((item) => item.placement.slotId).toSet(),
      hasLength(decorationCatalog.length),
      reason: 'Every decoration must have exactly one exclusive home.',
    );
    for (final item in decorationCatalog) {
      expect(item.placement.position.dx, inInclusiveRange(-.75, .75));
      expect(item.placement.position.dy, inInclusiveRange(-.65, .65));
      expect(item.placement.widthFactor, inInclusiveRange(.08, .95));
      final supportId = item.placement.supportItemId;
      if (supportId != null) {
        expect(
          decorationCatalog.indexWhere(
            (candidate) => candidate.id == supportId,
          ),
          lessThan(decorationCatalog.indexOf(item)),
          reason: '${item.id} must unlock after its support $supportId.',
        );
      }
    }
    final rug = decorationCatalog.firstWhere((item) => item.id == 'rug');
    final desk = decorationCatalog.firstWhere((item) => item.id == 'desk');
    final cat = decorationCatalog.firstWhere(
      (item) => item.id == 'sleeping_cat',
    );
    expect(rug.placement.layer.index, lessThan(desk.placement.layer.index));
    expect(cat.placement.layer.index, greaterThan(desk.placement.layer.index));
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

  test('completed room forms one connected study composition', () {
    const canvasWidth = 899.0;
    const canvasHeight = 1748.0;
    ui.Rect bounds(DecorationItem item) {
      final size = canvasWidth * item.placement.widthFactor;
      final position = item.placement.position;
      return ui.Rect.fromLTWH(
        (canvasWidth - size) / 2 * (1 + position.dx),
        (canvasHeight - size) / 2 * (1 + position.dy),
        size,
        size,
      );
    }

    DecorationItem item(String id) {
      return decorationCatalog.firstWhere((candidate) => candidate.id == id);
    }

    final desk = bounds(item('desk'));
    final chair = bounds(item('chair'));
    final rug = bounds(item('rug'));
    final bookshelf = bounds(item('bookshelf'));
    final plant = bounds(item('potted_plant'));
    final lamp = bounds(item('desk_lamp'));
    final candle = bounds(item('candle'));
    final cat = bounds(item('sleeping_cat'));
    final wallArt = bounds(item('wall_art'));
    final hangingPlant = bounds(item('hanging_plant'));

    expect(rug.contains(chair.center), isTrue);
    expect(rug.contains(cat.center), isTrue);
    expect(desk.contains(lamp.center), isTrue);
    expect(desk.contains(candle.center), isTrue);
    expect(chair.center.dx, closeTo(desk.center.dx, 100));
    expect(chair.top, lessThan(desk.bottom));
    expect(bookshelf.center.dx, greaterThan(desk.center.dx));
    expect(bookshelf.left, lessThan(desk.right + 80));
    expect(plant.center.dx, greaterThan(desk.center.dx));
    expect(plant.left, lessThan(bookshelf.right + 50));
    expect(wallArt.center.dx, closeTo(bookshelf.center.dx, 120));
    expect(wallArt.bottom, lessThan(desk.top));
    expect(
      hangingPlant.center.dx,
      inInclusiveRange(desk.center.dx, bookshelf.center.dx),
    );
    expect(hangingPlant.bottom, lessThan(desk.top));
  });

  test('gentle goal decor has fixed room homes and valid supports', () {
    expect(
      dailyDecorationCatalog.map((item) => item.placement.slotId).toSet(),
      hasLength(dailyDecorationCatalog.length),
    );
    for (final item in dailyDecorationCatalog) {
      expect(item.placement.position.dx, inInclusiveRange(-.80, .80));
      expect(item.placement.position.dy, inInclusiveRange(-.65, .65));
      expect(item.placement.widthFactor, inInclusiveRange(.08, .35));
      final supportId = item.placement.supportItemId;
      if (supportId != null) {
        expect(
          decorationCatalog.any((mainItem) => mainItem.id == supportId),
          isTrue,
          reason: '${item.id} must reference a real main-room support.',
        );
      }
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
