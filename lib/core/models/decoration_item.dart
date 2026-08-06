import 'package:flutter/material.dart';

import '../assets/app_assets.dart';

enum RoomSlotType { floor, wall, ceiling, tabletop }

enum RoomItemLayer { wall, floorBack, floorMiddle, floorFront, tabletop, light }

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
  final String craftAssetPath;
  final int craftAtlasRows;
  final int craftAtlasRow;

  double get contentAspectRatio => atlasCrop.width / atlasCrop.height;
}

class CollectibleDecoration {
  const CollectibleDecoration({
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'floor_back_left',
    defaultPosition: Offset(-.34, .04),
    widthFactor: .48,
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorMiddle,
    defaultSlotId: 'floor_middle_left',
    defaultPosition: Offset(-.18, .29),
    widthFactor: .36,
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
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.light,
    defaultSlotId: 'table_left',
    defaultPosition: Offset(-.42, -.04),
    widthFactor: .20,
    isInteractive: true,
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'floor_front_center',
    defaultPosition: Offset(.02, .62),
    widthFactor: .68,
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorMiddle,
    defaultSlotId: 'floor_middle_right',
    defaultPosition: Offset(.47, .24),
    widthFactor: .28,
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorBack,
    defaultSlotId: 'floor_back_right',
    defaultPosition: Offset(.44, -.02),
    widthFactor: .40,
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
    slotType: RoomSlotType.tabletop,
    layer: RoomItemLayer.light,
    defaultSlotId: 'table_right',
    defaultPosition: Offset(-.07, .00),
    widthFactor: .14,
    isInteractive: true,
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
    slotType: RoomSlotType.wall,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'wall_right',
    defaultPosition: Offset(.43, -.56),
    widthFactor: .24,
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
    slotType: RoomSlotType.ceiling,
    layer: RoomItemLayer.wall,
    defaultSlotId: 'ceiling_right',
    defaultPosition: Offset(.62, -.55),
    widthFactor: .28,
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
    slotType: RoomSlotType.floor,
    layer: RoomItemLayer.floorFront,
    defaultSlotId: 'floor_front_right',
    defaultPosition: Offset(.43, .58),
    widthFactor: .34,
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
  ),
  CollectibleDecoration(
    id: 'book_stack',
    name: 'Book Stack',
    atlasColumn: 1,
    atlasRow: 0,
  ),
  CollectibleDecoration(
    id: 'tiny_vase',
    name: 'Tiny Vase',
    atlasColumn: 2,
    atlasRow: 0,
  ),
  CollectibleDecoration(
    id: 'starflower',
    name: 'Starflower',
    atlasColumn: 3,
    atlasRow: 0,
  ),
  CollectibleDecoration(
    id: 'night_fern',
    name: 'Night Fern',
    atlasColumn: 0,
    atlasRow: 1,
  ),
  CollectibleDecoration(
    id: 'owl_figure',
    name: 'Owl Figure',
    atlasColumn: 1,
    atlasRow: 1,
  ),
  CollectibleDecoration(
    id: 'leaf_lantern',
    name: 'Leaf Lantern',
    atlasColumn: 2,
    atlasRow: 1,
  ),
  CollectibleDecoration(
    id: 'desk_clock',
    name: 'Desk Clock',
    atlasColumn: 3,
    atlasRow: 1,
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
