import 'package:flutter/material.dart';

import '../../core/models/badge_definition.dart';
import '../../core/models/decoration_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../../core/widgets/profile_avatar.dart';
import '../settings/settings_screen.dart';
import '../../l10n/localization_extensions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, String currentName) async {
    var draftName = currentName;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editProfile),
        content: TextFormField(
          initialValue: currentName,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: context.l10n.name,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => draftName = value,
          onFieldSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    if (value != null && context.mounted) {
      await AppScope.of(context).setUsername(value);
    }
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final controller = AppScope.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: .76,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            child: Column(
              children: [
                Text(
                  context.l10n.chooseProfilePicture,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.chooseProfilePictureBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: .82,
                        ),
                    itemCount: profileAvatarCatalog.length,
                    itemBuilder: (context, index) {
                      final avatar = profileAvatarCatalog[index];
                      final active = avatar.id == controller.profileAvatarId;
                      return InkWell(
                        onTap: () => Navigator.pop(context, avatar.id),
                        borderRadius: BorderRadius.circular(22),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: active
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: active
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    child: ProfileAvatar(
                                      avatarId: avatar.id,
                                      size: 78,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  context.l10n.avatarName(avatar),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await AppScope.of(context).setProfileAvatar(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n.appTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.settings,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: DesignTokens.softShadow,
                  ),
                  child: ProfileAvatar(
                    key: const Key('profile-avatar-edit'),
                    avatarId: controller.profileAvatarId,
                    size: 126,
                    showEditBadge: true,
                    onTap: () => _pickAvatar(context),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  context.l10n.tapPictureToChange,
                  style: Theme.of(context).textTheme.bodySmall,
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
                  child: Text(
                    context.l10n.zenMaster,
                    style: const TextStyle(color: AppColors.ink),
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
                  label: Text(context.l10n.editProfile),
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
                        label: context.l10n.focusHours,
                        tint: AppColors.sageSoft,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ProfileStat(
                        icon: Icons.local_fire_department_outlined,
                        value: '${controller.streakDays}',
                        label: context.l10n.dayStreak,
                        tint: AppColors.terracottaSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileStat(
                  icon: Icons.location_on_outlined,
                  value: '${controller.unlockedDecorationCount}',
                  label: context.l10n.decorations,
                  tint: AppColors.sand,
                  wide: true,
                ),
                const SizedBox(height: 42),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.earnedBadges,
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
                  itemCount: badgeCatalog.length,
                  itemBuilder: (context, index) {
                    final badge = badgeCatalog[index];
                    final unlocked =
                        controller.badgeProgress[badge.id]?.earnedAt != null;
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

class _Badge extends StatelessWidget {
  const _Badge({required this.data, required this.unlocked});

  final BadgeDefinition data;
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
              context.l10n.badgeName(data),
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
