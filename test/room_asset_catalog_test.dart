import 'dart:io';
import 'dart:ui' as ui;

import 'package:cozy_focus/core/assets/app_assets.dart';
import 'package:cozy_focus/core/models/decoration_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('room catalogs contain exactly the items retained in the Figma CSV', () {
    expect(decorationCatalog.map((item) => item.id).toList(), [
      'desk',
      'chair',
      'rug',
      'bookshelf',
      'candle',
      'wall_art',
      'hanging_plant',
      'sleeping_cat',
    ]);
    expect(dailyDecorationCatalog.map((item) => item.id).toList(), [
      'tea_cup',
      'night_fern',
      'owl_figure',
      'leaf_lantern',
    ]);
    expect(profileAvatarCatalog, hasLength(6));
  });

  test('Flutter placements match every filled Figma CSV value exactly', () {
    final allPlacements = <String, RoomPlacementSpec>{
      for (final item in decorationCatalog) item.id: item.placement,
      for (final item in dailyDecorationCatalog) item.id: item.placement,
    };
    final rows = File('design/figma_room_layout/figma_measurements.csv')
        .readAsLinesSync()
        .skip(1)
        .where((line) => line.trim().isNotEmpty)
        .where((line) => !line.startsWith('image_1,'))
        .toList();

    expect(rows, hasLength(allPlacements.length));
    for (final row in rows) {
      final cells = row.split(',');
      final id = cells[0];
      final placement = allPlacements[id];
      expect(placement, isNotNull, reason: '$id must exist in the app catalog');
      expect(
        placement!.figmaRect,
        ui.Rect.fromLTWH(
          double.parse(cells[1]),
          double.parse(cells[2]),
          double.parse(cells[3]),
          double.parse(cells[4]),
        ),
        reason: id,
      );
      expect(placement.figmaLayerOrder, int.parse(cells[5]), reason: id);
      final rotationMatch = RegExp(r'rotation=(\d+)').firstMatch(cells[6]);
      expect(
        placement.rotationDegrees,
        rotationMatch == null ? 0 : double.parse(rotationMatch.group(1)!),
        reason: id,
      );
    }
  });

  test('every Figma rect intersects the 899 x 1748 room canvas', () {
    final placements = [
      ...decorationCatalog.map((item) => item.placement),
      ...dailyDecorationCatalog.map((item) => item.placement),
    ];
    expect(placements.map((placement) => placement.figmaLayerOrder).toSet(), {
      for (var index = 1; index <= 12; index++) index,
    });
    for (final placement in placements) {
      expect(
        placement.figmaRect.overlaps(
          const ui.Rect.fromLTWH(0, 0, roomDesignWidth, roomDesignHeight),
        ),
        isTrue,
      );
      expect(placement.figmaRect.width, greaterThan(0));
      expect(placement.figmaRect.height, greaterThan(0));
    }
  });

  test('support relationships reference retained anchors', () {
    final mainIds = decorationCatalog.map((item) => item.id).toSet();
    final entries = <({String id, String? supportId})>[
      for (final item in decorationCatalog)
        (id: item.id, supportId: item.placement.supportItemId),
      for (final item in dailyDecorationCatalog)
        (id: item.id, supportId: item.placement.supportItemId),
    ];
    for (final entry in entries) {
      final supportId = entry.supportId;
      if (supportId != null) {
        expect(mainIds, contains(supportId), reason: entry.id);
      }
    }
  });

  test('desk group keeps the exact Figma front-to-back order', () {
    final desk = decorationCatalog
        .firstWhere((item) => item.id == 'desk')
        .placement;
    final chair = decorationCatalog
        .firstWhere((item) => item.id == 'chair')
        .placement;
    final candle = decorationCatalog
        .firstWhere((item) => item.id == 'candle')
        .placement;
    final tea = dailyDecorationCatalog
        .firstWhere((item) => item.id == 'tea_cup')
        .placement;

    final rug = decorationCatalog
        .firstWhere((item) => item.id == 'rug')
        .placement;
    expect(rug.figmaLayerOrder, greaterThan(chair.figmaLayerOrder));
    expect(chair.figmaLayerOrder, greaterThan(desk.figmaLayerOrder));
    expect(candle.figmaLayerOrder, lessThan(desk.figmaLayerOrder));
    expect(tea.figmaLayerOrder, lessThan(desk.figmaLayerOrder));
    expect(candle.figmaRect, const ui.Rect.fromLTWH(127, 869, 142, 194));
    expect(tea.figmaRect, const ui.Rect.fromLTWH(475, 1015, 117, 95));
  });

  test('image_1 remains the locked full-room background', () {
    final row = File(
      'design/figma_room_layout/figma_measurements.csv',
    ).readAsLinesSync().firstWhere((line) => line.startsWith('image_1,'));
    expect(row, 'image_1,-1,0,899,1748,13,locked background');
  });

  test(
    'individual room sprites exist and preserve transparent corners',
    () async {
      final paths = {
        ...decorationCatalog.map((item) => item.assetPath),
        ...dailyDecorationCatalog.map((item) => item.assetPath),
      };
      expect(paths, hasLength(12));
      for (final path in paths) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        final codec = await ui.instantiateImageCodec(await file.readAsBytes());
        final frame = await codec.getNextFrame();
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(pixels, isNotNull, reason: path);
        expect(pixels!.getUint8(3), 0, reason: path);
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test('empty room background matches the Figma canvas', () async {
    final bytes = await File(AppAssets.emptyRoomBaseV2).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, roomDesignWidth);
    expect(frame.image.height, roomDesignHeight);
    frame.image.dispose();
    codec.dispose();
  });
}
