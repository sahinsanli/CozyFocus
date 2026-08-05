import 'package:flutter/material.dart';

import '../assets/app_assets.dart';

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
    this.atlasCrop = const Rect.fromLTWH(0, 0, 1, 1),
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

  double get contentAspectRatio => atlasCrop.width / atlasCrop.height;
}

const decorationCatalog = <DecorationItem>[
  DecorationItem(
    id: 'cactus',
    name: 'Moonleaf',
    category: 'Growing plant',
    unlockMinutes: 0,
    icon: Icons.local_florist_outlined,
    assetPath: AppAssets.plantGrowthAtlas,
    atlasColumns: 3,
    atlasRows: 3,
    atlasColumn: 0,
    atlasRow: 0,
  ),
  DecorationItem(
    id: 'bookshelf',
    name: 'Bookshelf',
    category: 'Furniture',
    unlockMinutes: 0,
    icon: Icons.shelves,
    assetPath: AppAssets.decorationAtlas,
    atlasColumns: 3,
    atlasRows: 3,
    atlasColumn: 1,
    atlasRow: 0,
    atlasCrop: Rect.fromLTRB(.11, .24, .94, 1),
  ),
  DecorationItem(
    id: 'sleeping_cat',
    name: 'Sleeping Cat',
    category: 'Companion',
    unlockMinutes: 50,
    icon: Icons.pets_outlined,
    assetPath: AppAssets.visitorAtlas,
    atlasColumns: 2,
    atlasRows: 2,
    atlasColumn: 1,
    atlasRow: 0,
    atlasCrop: Rect.fromLTRB(.02, .14, .90, .87),
  ),
  DecorationItem(
    id: 'hanging_plant',
    name: 'Hanging Plant',
    category: 'Decor',
    unlockMinutes: 120,
    icon: Icons.eco_outlined,
    assetPath: AppAssets.decorationAtlas,
    atlasColumns: 3,
    atlasRows: 3,
    atlasColumn: 1,
    atlasRow: 1,
    atlasCrop: Rect.fromLTRB(.14, 0, 1, .93),
  ),
  DecorationItem(
    id: 'armchair',
    name: 'Cozy Armchair',
    category: 'Furniture',
    unlockMinutes: 240,
    icon: Icons.chair_outlined,
    assetPath: AppAssets.decorationAtlas,
    atlasColumns: 3,
    atlasRows: 3,
    atlasColumn: 0,
    atlasRow: 0,
    atlasCrop: Rect.fromLTRB(.13, .14, .98, 1),
  ),
];
