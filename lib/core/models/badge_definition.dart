import 'package:flutter/material.dart';

enum BadgeCriterion {
  firstFocus,
  firstClaim,
  firstDailyGoal,
  soundMixer,
  totalFocusMinutes,
  roomComplete,
}

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.criterion,
    required this.icon,
    required this.color,
    this.threshold = 1,
  });

  final String id;
  final String name;
  final String description;
  final BadgeCriterion criterion;
  final IconData icon;
  final Color color;
  final int threshold;
}

const badgeCatalog = <BadgeDefinition>[
  BadgeDefinition(
    id: 'first_focus',
    name: 'First Bloom',
    description: 'Complete your first focus session.',
    criterion: BadgeCriterion.firstFocus,
    icon: Icons.timer_outlined,
    color: Color(0xFF71866A),
  ),
  BadgeDefinition(
    id: 'first_claim',
    name: 'Room Maker',
    description: 'Claim your first crafted room item.',
    criterion: BadgeCriterion.firstClaim,
    icon: Icons.inventory_2_outlined,
    color: Color(0xFFB66C57),
  ),
  BadgeDefinition(
    id: 'first_daily_goal',
    name: 'Gentle Keeper',
    description: 'Complete your first daily focus goal.',
    criterion: BadgeCriterion.firstDailyGoal,
    icon: Icons.redeem_outlined,
    color: Color(0xFFD19B52),
  ),
  BadgeDefinition(
    id: 'sound_weaver',
    name: 'Sound Weaver',
    description: 'Play two ambient sounds together.',
    criterion: BadgeCriterion.soundMixer,
    icon: Icons.graphic_eq_rounded,
    color: Color(0xFF6C7E91),
  ),
  BadgeDefinition(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Reach 120 total focus minutes.',
    criterion: BadgeCriterion.totalFocusMinutes,
    threshold: 120,
    icon: Icons.nightlight_outlined,
    color: Color(0xFF766F57),
  ),
  BadgeDefinition(
    id: 'deep_woods',
    name: 'Deep Woods',
    description: 'Reach 300 total focus minutes.',
    criterion: BadgeCriterion.totalFocusMinutes,
    threshold: 300,
    icon: Icons.forest_outlined,
    color: Color(0xFFB66C57),
  ),
  BadgeDefinition(
    id: 'zen_keeper',
    name: 'Zen Keeper',
    description: 'Reach 600 total focus minutes.',
    criterion: BadgeCriterion.totalFocusMinutes,
    threshold: 600,
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF8FA488),
  ),
  BadgeDefinition(
    id: 'room_complete',
    name: 'Sanctuary Complete',
    description: 'Claim every main room item.',
    criterion: BadgeCriterion.roomComplete,
    icon: Icons.home_outlined,
    color: Color(0xFF71866A),
  ),
];
