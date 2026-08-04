import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, String currentName) async {
    var draftName = currentName;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextFormField(
          initialValue: currentName,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => draftName = value,
          onFieldSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value != null && context.mounted) {
      await AppScope.of(context).setUsername(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final badges = <_BadgeData>[
      _BadgeData('First Bloom', Icons.spa_outlined, AppColors.sage, 25),
      _BadgeData(
        'Night Owl',
        Icons.nightlight_outlined,
        const Color(0xFF766F57),
        120,
      ),
      _BadgeData(
        'Deep Woods',
        Icons.forest_outlined,
        AppColors.terracotta,
        300,
      ),
      _BadgeData(
        'Zen Keeper',
        Icons.self_improvement_outlined,
        AppColors.sageMid,
        600,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cozy Focus Room',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 126,
                      height: 126,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sageSoft,
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: DesignTokens.softShadow,
                      ),
                      child: Center(
                        child: Text(
                          controller.username.characters.first.toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppColors.sage, fontSize: 52),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -2,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sageMid,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  controller.username,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: const Text(
                    '🌱  Zen Master',
                    style: TextStyle(color: AppColors.ink),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: () => _editName(context, controller.username),
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
                const SizedBox(height: 38),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        icon: Icons.timer_outlined,
                        value: (controller.allTimeMinutes / 60).toStringAsFixed(
                          1,
                        ),
                        label: 'Focus Hours',
                        tint: AppColors.sageSoft,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ProfileStat(
                        icon: Icons.local_fire_department_outlined,
                        value: '${controller.streakDays}',
                        label: 'Day Streak',
                        tint: AppColors.terracottaSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileStat(
                  icon: Icons.location_on_outlined,
                  value: '${controller.unlockedDecorationCount}',
                  label: 'Decorations',
                  tint: AppColors.sand,
                  wide: true,
                ),
                const SizedBox(height: 42),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Earned Badges',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .82,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    final unlocked =
                        controller.allTimeMinutes >= badge.threshold;
                    return _Badge(data: badge, unlocked: unlocked);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    this.wide = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CozyCard(
        padding: EdgeInsets.symmetric(vertical: wide ? 28 : 24, horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: tint,
              foregroundColor: AppColors.ink,
              child: Icon(icon),
            ),
            const SizedBox(height: 14),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeData {
  const _BadgeData(this.name, this.icon, this.color, this.threshold);
  final String name;
  final IconData icon;
  final Color color;
  final int threshold;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.data, required this.unlocked});

  final _BadgeData data;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : .48,
      child: CozyCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? data.icon : Icons.lock_outline,
              size: 38,
              color: unlocked ? data.color : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              unlocked ? data.name : '${data.threshold}m',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
