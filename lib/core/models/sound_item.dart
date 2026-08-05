import 'package:flutter/material.dart';

class SoundItem {
  const SoundItem(
    this.id,
    this.name,
    this.icon, {
    required this.previewColumn,
    required this.previewRow,
    required this.previewCrop,
  });

  final String id;
  final String name;
  final IconData icon;
  final int previewColumn;
  final int previewRow;
  final Rect previewCrop;
}

const soundCatalog = <SoundItem>[
  SoundItem(
    'rain',
    'Rainy Night',
    Icons.thunderstorm_outlined,
    previewColumn: 0,
    previewRow: 0,
    previewCrop: Rect.fromLTRB(.12, .04, .98, 1),
  ),
  SoundItem(
    'fire',
    'Cracking Fire',
    Icons.fireplace_outlined,
    previewColumn: 1,
    previewRow: 0,
    previewCrop: Rect.fromLTRB(.02, .04, .88, 1),
  ),
  SoundItem(
    'cafe',
    'Quiet Cafe',
    Icons.local_cafe_outlined,
    previewColumn: 0,
    previewRow: 1,
    previewCrop: Rect.fromLTRB(.12, .09, .98, .98),
  ),
  SoundItem(
    'forest',
    'Deep Forest',
    Icons.forest_outlined,
    previewColumn: 1,
    previewRow: 1,
    previewCrop: Rect.fromLTRB(.02, .09, .88, .98),
  ),
  SoundItem(
    'piano',
    'Soft Piano',
    Icons.piano_outlined,
    previewColumn: 0,
    previewRow: 2,
    previewCrop: Rect.fromLTRB(.12, .02, .98, .97),
  ),
  SoundItem(
    'pond',
    'Moonlit Pond',
    Icons.water_outlined,
    previewColumn: 1,
    previewRow: 2,
    previewCrop: Rect.fromLTRB(.02, .02, .88, .97),
  ),
];
