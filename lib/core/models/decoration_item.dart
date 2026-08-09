import 'package:flutter/material.dart';

import '../assets/app_assets.dart';

const roomDesignWidth = 899.0;
const roomDesignHeight = 1748.0;

enum RoomSlotType { floor, wall, ceiling, tabletop }

enum RoomItemLayer {
  wall,
  floorFoundation,
  floorBack,
  floorMiddle,
  tabletop,
  floorFront,
  light,
}

/// A room item's immutable Figma placement on the 899 x 1748 design canvas.
///
/// `figmaLayerOrder` follows Figma's layer panel: 1 is front-most. The legacy
/// normalized position getters remain only for save-file compatibility.
class RoomPlacementSpec {
  const RoomPlacementSpec({
    required this.slotId,
    required this.figmaRect,
    required this.figmaLayerOrder,
    required this.layer,
    this.rotationDegrees = 0,
    this.supportItemId,
  });

  final String slotId;
  final Rect figmaRect;
  final int figmaLayerOrder;
  final double rotationDegrees;
  final RoomItemLayer layer;
  final String? supportItemId;

  Offset get position {
    final horizontalTravel = roomDesignWidth - figmaRect.width;
    final verticalTravel = roomDesignHeight - figmaRect.height;
    return Offset(
      horizontalTravel <= 0 ? 0 : figmaRect.left / horizontalTravel * 2 - 1,
      verticalTravel <= 0 ? 0 : figmaRect.top / verticalTravel * 2 - 1,
    );
  }

  double get widthFactor => figmaRect.width / roomDesignWidth;
}

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unlockMinutes,
    required this.icon,
    required this.assetPath,
    required this.slotType,
    required this.layer,
    required this.defaultSlotId,
    required this.figmaRect,
    required this.figmaLayerOrder,
    required this.craftAssetPath,
    required this.craftAtlasRows,
    required this.craftAtlasRow,
    this.rotationDegrees = 0,
    this.isInteractive = false,
    this.supportItemId,
  });

  final String id;
  final String name;
  final String category;
  final int unlockMinutes;
  final IconData icon;
  final String assetPath;
  final RoomSlotType slotType;
  final RoomItemLayer layer;
  final String defaultSlotId;
  final Rect figmaRect;
  final int figmaLayerOrder;
  final double rotationDegrees;
  final bool isInteractive;
  final String? supportItemId;
  final String craftAssetPath;
  final int craftAtlasRows;
  final int craftAtlasRow;

  // Individual room sprites use a single full-frame image. These accessors
  // keep focus/inventory previews compatible with AtlasSprite.
  int get atlasColumns => 1;
  int get atlasRows => 1;
  int get atlasColumn => 0;
  int get atlasRow => 0;
  Rect get atlasCrop => const Rect.fromLTWH(0, 0, 1, 1);
  Offset get defaultPosition => placement.position;
  double get widthFactor => placement.widthFactor;
  double get contentAspectRatio => figmaRect.width / figmaRect.height;

  RoomPlacementSpec get placement => RoomPlacementSpec(
    slotId: defaultSlotId,
    figmaRect: figmaRect,
    figmaLayerOrder: figmaLayerOrder,
    rotationDegrees: rotationDegrees,
    layer: layer,
    supportItemId: supportItemId,
  );
}

class CollectibleDecoration {
  const CollectibleDecoration({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.slotType,
    required this.layer,
    required this.defaultSlotId,
    required this.figmaRect,
    required this.figmaLayerOrder,
    this.rotationDegrees = 0,
    this.supportItemId,
  });

  final String id;
  final String name;
  final String assetPath;
  final RoomSlotType slotType;
  final RoomItemLayer layer;
  final String defaultSlotId;
  final Rect figmaRect;
  final int figmaLayerOrder;
  final double rotationDegrees;
  final String? supportItemId;

  int get atlasColumn => 0;
  int get atlasRow => 0;
  Rect get atlasCrop => const Rect.fromLTWH(0, 0, 1, 1);
  Offset get defaultPosition => placement.position;
  double get widthFactor => placement.widthFactor;
  double get contentAspectRatio => figmaRect.width / figmaRect.height;

  RoomPlacementSpec get placement => RoomPlacementSpec(
    slotId: defaultSlotId,
    figmaRect: figmaRect,
    figmaLayerOrder: figmaLayerOrder,
    rotationDegrees: rotationDegrees,
    layer: layer,
    supportItemId: supportItemId,
  );
}

class ProfileAvatarItem {
  const ProfileAvatarItem({
    required this.id,
    required this.name,
    required this.atlasColumn,
    required this.atlasRow,
  });

  final String id;
  final String name;
  final int atlasColumn;
  final int atlasRow;
}

const decorationCatalog = <DecorationItem>[
  DecorationItem(
    id: 'desk',
    name: 'Study Desk',
    category: 'Furniture',
    unlockMinutes: 30,
    icon: Icons.desk_outlined,
    assetPath: AppAssets.roomDesk,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorMiddle,
    defaultSlotId: 'desk_home',
    figmaRect: Rect.fromLTWH(90, 884, 631, 650),
    figmaLayerOrder: 9,
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 0,
  ),
  DecorationItem(
    id: 'chair',
    name: 'Study Chair',
    category: 'Furniture',
    unlockMinutes: 60,
    icon: Icons.chair_alt_outlined,
    assetPath: AppAssets.roomChair,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'chair_home',
    figmaRect: Rect.fromLTWH(127, 845, 650, 642),
    figmaLayerOrder: 10,
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 1,
  ),
  DecorationItem(
    id: 'rug',
    name: 'Botanical Rug',
    category: 'Floor decor',
    unlockMinutes: 120,
    icon: Icons.circle_outlined,
    assetPath: AppAssets.roomRug,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFoundation,
    defaultSlotId: 'rug_home',
    figmaRect: Rect.fromLTWH(-23, 996, 944, 752),
    figmaLayerOrder: 11,
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 3,
  ),
  DecorationItem(
    id: 'bookshelf',
    name: 'Bookshelf',
    category: 'Furniture',
    unlockMinutes: 210,
    icon: Icons.shelves,
    assetPath: AppAssets.roomBookshelf,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'bookshelf_home',
    figmaRect: Rect.fromLTWH(475, 487, 420, 397),
    figmaLayerOrder: 12,
    craftAssetPath: AppAssets.craftingAtlasBV2,
    craftAtlasRows: 4,
    craftAtlasRow: 1,
  ),
  DecorationItem(
    id: 'candle',
    name: 'Moon Candle',
    category: 'Lighting',
    unlockMinutes: 255,
    icon: Icons.local_fire_department_outlined,
    assetPath: AppAssets.roomCandle,
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'candle_on_desk',
    figmaRect: Rect.fromLTWH(127, 869, 142, 194),
    figmaLayerOrder: 4,
    isInteractive: true,
    supportItemId: 'desk',
    craftAssetPath: AppAssets.craftingAtlasBV2,
    craftAtlasRows: 4,
    craftAtlasRow: 2,
  ),
  DecorationItem(
    id: 'wall_art',
    name: 'Botanical Print',
    category: 'Wall decor',
    unlockMinutes: 300,
    icon: Icons.image_outlined,
    assetPath: AppAssets.roomWallArt,
    slotType: RoomSlotType.wall,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'wall_art_home',
    figmaRect: Rect.fromLTWH(685, 65, 210, 278),
    figmaLayerOrder: 1,
    craftAssetPath: AppAssets.craftingAtlasBV2,
    craftAtlasRows: 4,
    craftAtlasRow: 3,
  ),
  DecorationItem(
    id: 'hanging_plant',
    name: 'Hanging Plant',
    category: 'Ceiling decor',
    unlockMinutes: 345,
    icon: Icons.eco_outlined,
    assetPath: AppAssets.roomHangingPlant,
    slotType: RoomSlotType.ceiling,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'hanging_plant_home',
    figmaRect: Rect.fromLTWH(120, 120, 202, 315),
    figmaLayerOrder: 8,
    craftAssetPath: AppAssets.craftingAtlasCV2,
    craftAtlasRows: 2,
    craftAtlasRow: 0,
  ),
  DecorationItem(
    id: 'sleeping_cat',
    name: 'Sleeping Cat',
    category: 'Companion',
    unlockMinutes: 390,
    icon: Icons.pets_outlined,
    assetPath: AppAssets.roomSleepingCat,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'cat_on_rug',
    figmaRect: Rect.fromLTWH(154, 1427, 321, 261),
    figmaLayerOrder: 3,
    supportItemId: 'rug',
    craftAssetPath: AppAssets.craftingAtlasCV2,
    craftAtlasRows: 2,
    craftAtlasRow: 1,
  ),
];

const dailyDecorationCatalog = <CollectibleDecoration>[
  CollectibleDecoration(
    id: 'tea_cup',
    name: 'Moon Tea',
    assetPath: AppAssets.roomTeaCup,
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'tea_on_desk',
    figmaRect: Rect.fromLTWH(475, 1015, 117, 95),
    figmaLayerOrder: 2,
    supportItemId: 'desk',
  ),
  CollectibleDecoration(
    id: 'night_fern',
    name: 'Night Fern',
    assetPath: AppAssets.roomNightFern,
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'fern_by_window',
    figmaRect: Rect.fromLTWH(90, 547, 262, 277),
    figmaLayerOrder: 6,
  ),
  CollectibleDecoration(
    id: 'owl_figure',
    name: 'Owl Figure',
    assetPath: AppAssets.roomOwlFigure,
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'owl_on_shelf',
    figmaRect: Rect.fromLTWH(558, 389, 103, 134),
    figmaLayerOrder: 5,
    supportItemId: 'bookshelf',
  ),
  CollectibleDecoration(
    id: 'leaf_lantern',
    name: 'Leaf Lantern',
    assetPath: AppAssets.roomLeafLantern,
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.light,
    defaultSlotId: 'lantern_on_shelf',
    figmaRect: Rect.fromLTWH(687, 343, 112, 183),
    figmaLayerOrder: 7,
    supportItemId: 'bookshelf',
  ),
];

const profileAvatarCatalog = <ProfileAvatarItem>[
  ProfileAvatarItem(
    id: 'moonleaf',
    name: 'Moonleaf',
    atlasColumn: 0,
    atlasRow: 2,
  ),
  ProfileAvatarItem(id: 'cat', name: 'Sleepy Cat', atlasColumn: 1, atlasRow: 2),
  ProfileAvatarItem(
    id: 'moon',
    name: 'Crescent Moon',
    atlasColumn: 2,
    atlasRow: 2,
  ),
  ProfileAvatarItem(id: 'lamp', name: 'Cozy Lamp', atlasColumn: 3, atlasRow: 2),
  ProfileAvatarItem(
    id: 'forest',
    name: 'Night Forest',
    atlasColumn: 0,
    atlasRow: 3,
  ),
  ProfileAvatarItem(id: 'tea', name: 'Moon Tea', atlasColumn: 1, atlasRow: 3),
];
