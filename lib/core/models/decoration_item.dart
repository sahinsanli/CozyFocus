import 'package:flutter/material.dart';

import '../assets/app_assets.dart';

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

/// The single canonical home of a decoration in the finished room.
///
/// Positions use Flutter's normalized Alignment coordinate space (-1...1).
/// They are catalog-owned so saved user data can never create a conflicting
/// second layout.
class RoomPlacementSpec {
  const RoomPlacementSpec({
    required this.slotId,
    required this.position,
    required this.widthFactor,
    required this.layer,
    this.supportItemId,
  });

  final String slotId;
  final Offset position;
  final double widthFactor;
  final RoomItemLayer layer;
  final String? supportItemId;
}

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unlockMinutes,
    required this.icon,
    required this.assetPath,
    required this.atlasColumns,
    required this.atlasRows,
    required this.atlasColumn,
    required this.atlasRow,
    required this.slotType,
    required this.layer,
    required this.defaultSlotId,
    required this.defaultPosition,
    required this.widthFactor,
    required this.craftAssetPath,
    required this.craftAtlasRows,
    required this.craftAtlasRow,
    this.atlasCrop = const Rect.fromLTWH(0, 0, 1, 1),
    this.isInteractive = false,
    this.supportItemId,
  });

  final String id;
  final String name;
  final String category;
  final int unlockMinutes;
  final IconData icon;
  final String assetPath;
  final int atlasColumns;
  final int atlasRows;
  final int atlasColumn;
  final int atlasRow;
  final Rect atlasCrop;
  final RoomSlotType slotType;
  final RoomItemLayer layer;
  final String defaultSlotId;
  final Offset defaultPosition;
  final double widthFactor;
  final bool isInteractive;
  final String? supportItemId;
  final String craftAssetPath;
  final int craftAtlasRows;
  final int craftAtlasRow;

  double get contentAspectRatio => atlasCrop.width / atlasCrop.height;

  RoomPlacementSpec get placement => RoomPlacementSpec(
    slotId: defaultSlotId,
    position: defaultPosition,
    widthFactor: widthFactor,
    layer: layer,
    supportItemId: supportItemId,
  );
}

class CollectibleDecoration {
  const CollectibleDecoration({
    required this.id,
    required this.name,
    required this.atlasColumn,
    required this.atlasRow,
    required this.atlasCrop,
    required this.slotType,
    required this.layer,
    required this.defaultSlotId,
    required this.defaultPosition,
    required this.widthFactor,
    this.supportItemId,
  });

  final String id;
  final String name;
  final int atlasColumn;
  final int atlasRow;
  final Rect atlasCrop;
  final RoomSlotType slotType;
  final RoomItemLayer layer;
  final String defaultSlotId;
  final Offset defaultPosition;
  final double widthFactor;
  final String? supportItemId;

  double get contentAspectRatio => atlasCrop.width / atlasCrop.height;

  RoomPlacementSpec get placement => RoomPlacementSpec(
    slotId: defaultSlotId,
    position: defaultPosition,
    widthFactor: widthFactor,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 0,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.18, .15, .82, .83),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorMiddle,
    defaultSlotId: 'desk_home',
    defaultPosition: Offset(-.14, .15),
    widthFactor: .64,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 1,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(0, .12, .89, .87),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'chair_home',
    defaultPosition: Offset(-.03, .36),
    widthFactor: .37,
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 1,
  ),
  DecorationItem(
    id: 'desk_lamp',
    name: 'Desk Lamp',
    category: 'Lighting',
    unlockMinutes: 90,
    icon: Icons.light_outlined,
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 2,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.25, .12, .55, .86),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'lamp_on_desk',
    defaultPosition: Offset(-.42, -.23),
    widthFactor: .16,
    isInteractive: true,
    supportItemId: 'desk',
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 2,
  ),
  DecorationItem(
    id: 'rug',
    name: 'Botanical Rug',
    category: 'Floor decor',
    unlockMinutes: 120,
    icon: Icons.circle_outlined,
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 3,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(0, .28, .82, .64),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFoundation,
    defaultSlotId: 'rug_home',
    defaultPosition: Offset(-.02, .45),
    widthFactor: .92,
    craftAssetPath: AppAssets.craftingAtlasAV2,
    craftAtlasRows: 4,
    craftAtlasRow: 3,
  ),
  DecorationItem(
    id: 'potted_plant',
    name: 'Moonleaf Plant',
    category: 'Growing plant',
    unlockMinutes: 165,
    icon: Icons.local_florist_outlined,
    assetPath: AppAssets.rewardAvatarAtlasV2,
    atlasColumns: 4,
    atlasRows: 4,
    atlasColumn: 0,
    atlasRow: 2,
    atlasCrop: Rect.fromLTWH(.22, 0, .63, .93),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorMiddle,
    defaultSlotId: 'plant_home',
    defaultPosition: Offset(.70, .34),
    widthFactor: .23,
    craftAssetPath: AppAssets.craftingAtlasBV2,
    craftAtlasRows: 4,
    craftAtlasRow: 0,
  ),
  DecorationItem(
    id: 'bookshelf',
    name: 'Bookshelf',
    category: 'Furniture',
    unlockMinutes: 210,
    icon: Icons.shelves,
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 1,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.15, .18, .77, .72),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'bookshelf_home',
    defaultPosition: Offset(.74, -.18),
    widthFactor: .46,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 2,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.19, .17, .58, .79),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'candle_on_desk',
    defaultPosition: Offset(-.08, -.16),
    widthFactor: .10,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 3,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.13, .15, .57, .75),
    slotType: RoomSlotType.wall,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'wall_art_home',
    defaultPosition: Offset(.52, -.42),
    widthFactor: .22,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 0,
    atlasRow: 2,
    atlasCrop: Rect.fromLTWH(.28, 0, .55, .88),
    slotType: RoomSlotType.ceiling,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'hanging_plant_home',
    defaultPosition: Offset(.04, -.48),
    widthFactor: .26,
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
    assetPath: AppAssets.mainItemAtlasV2,
    atlasColumns: 4,
    atlasRows: 3,
    atlasColumn: 1,
    atlasRow: 2,
    atlasCrop: Rect.fromLTWH(.08, .07, .88, .71),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'cat_on_rug',
    defaultPosition: Offset(.30, .51),
    widthFactor: .26,
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
    atlasColumn: 0,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.17, .22, .83, .70),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'tea_on_desk',
    defaultPosition: Offset(.17, -.12),
    widthFactor: .11,
    supportItemId: 'desk',
  ),
  CollectibleDecoration(
    id: 'book_stack',
    name: 'Book Stack',
    atlasColumn: 1,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.14, .21, .82, .76),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'books_on_shelf',
    defaultPosition: Offset(.58, -.01),
    widthFactor: .14,
    supportItemId: 'bookshelf',
  ),
  CollectibleDecoration(
    id: 'tiny_vase',
    name: 'Tiny Vase',
    atlasColumn: 2,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.27, .09, .45, .88),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'vase_on_shelf',
    defaultPosition: Offset(.13, -.34),
    widthFactor: .09,
    supportItemId: 'bookshelf',
  ),
  CollectibleDecoration(
    id: 'starflower',
    name: 'Starflower',
    atlasColumn: 3,
    atlasRow: 0,
    atlasCrop: Rect.fromLTWH(.06, .08, .72, .88),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'starflower_by_window',
    defaultPosition: Offset(-.58, -.13),
    widthFactor: .16,
  ),
  CollectibleDecoration(
    id: 'night_fern',
    name: 'Night Fern',
    atlasColumn: 0,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.16, .10, .83, .90),
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'fern_by_window',
    defaultPosition: Offset(-.76, -.24),
    widthFactor: .34,
  ),
  CollectibleDecoration(
    id: 'owl_figure',
    name: 'Owl Figure',
    atlasColumn: 1,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.20, .15, .62, .80),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'owl_on_shelf',
    defaultPosition: Offset(.68, -.32),
    widthFactor: .11,
    supportItemId: 'bookshelf',
  ),
  CollectibleDecoration(
    id: 'leaf_lantern',
    name: 'Leaf Lantern',
    atlasColumn: 2,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.18, .05, .58, .90),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.light,
    defaultSlotId: 'lantern_on_shelf',
    defaultPosition: Offset(.40, -.33),
    widthFactor: .10,
    supportItemId: 'bookshelf',
  ),
  CollectibleDecoration(
    id: 'desk_clock',
    name: 'Desk Clock',
    atlasColumn: 3,
    atlasRow: 1,
    atlasCrop: Rect.fromLTWH(.05, .17, .68, .72),
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.tabletop,
    defaultSlotId: 'clock_on_desk',
    defaultPosition: Offset(.34, -.14),
    widthFactor: .10,
    supportItemId: 'desk',
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
