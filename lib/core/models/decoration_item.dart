import 'package:flutter/material.dart';

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unlockMinutes,
    required this.icon,
    required this.emoji,
  });

  final String id;
  final String name;
  final String category;
  final int unlockMinutes;
  final IconData icon;
  final String emoji;
}

const decorationCatalog = <DecorationItem>[
  DecorationItem(
    id: 'cactus',
    name: 'Cactus',
    category: 'Decor',
    unlockMinutes: 0,
    icon: Icons.local_florist_outlined,
    emoji: '🌵',
  ),
  DecorationItem(
    id: 'bookshelf',
    name: 'Bookshelf',
    category: 'Furniture',
    unlockMinutes: 0,
    icon: Icons.shelves,
    emoji: '📚',
  ),
  DecorationItem(
    id: 'sleeping_cat',
    name: 'Sleeping Cat',
    category: 'Companion',
    unlockMinutes: 50,
    icon: Icons.pets_outlined,
    emoji: '🐈',
  ),
  DecorationItem(
    id: 'hanging_plant',
    name: 'Hanging Plant',
    category: 'Decor',
    unlockMinutes: 120,
    icon: Icons.eco_outlined,
    emoji: '🌿',
  ),
  DecorationItem(
    id: 'armchair',
    name: 'Cozy Armchair',
    category: 'Furniture',
    unlockMinutes: 240,
    icon: Icons.chair_outlined,
    emoji: '🪑',
  ),
];
