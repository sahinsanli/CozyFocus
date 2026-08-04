import 'package:flutter/material.dart';

class SoundItem {
  const SoundItem(this.id, this.name, this.icon);

  final String id;
  final String name;
  final IconData icon;
}

const soundCatalog = <SoundItem>[
  SoundItem('rain', 'Rainy Night', Icons.thunderstorm_outlined),
  SoundItem('fire', 'Cracking Fire', Icons.fireplace_outlined),
  SoundItem('cafe', 'Quiet Cafe', Icons.local_cafe_outlined),
  SoundItem('forest', 'Deep Forest', Icons.forest_outlined),
  SoundItem('piano', 'Soft Piano', Icons.piano_outlined),
];
