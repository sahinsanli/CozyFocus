import 'package:flutter/material.dart';

import 'core/models/badge_definition.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/design_tokens.dart';
import 'core/widgets/app_scope.dart';
import 'core/widgets/profile_avatar.dart';
import 'features/focus/focus_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/room/room_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/sounds/sounds_screen.dart';
import 'features/stats/stats_screen.dart';
import 'l10n/localization_extensions.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    FocusScreen(),
    RoomScreen(),
    StatsScreen(),
    SoundsScreen(),
  ];

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    if (controller.roomPlacementRequestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_index != 1) setState(() => _index = 1);
        controller.acknowledgeRoomPlacementRequest();
      });
    }
    final badge = controller.nextBadgeCelebration;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: .9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        toolbarHeight: 68,
        leadingWidth: 64,
        leading: IconButton(
          tooltip: l10n.settings,
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        title: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Semantics(
              button: true,
              label: l10n.openProfile,
              child: InkWell(
                key: const Key('profile-button'),
                onTap: _openProfile,
                customBorder: const CircleBorder(),
                child: ProfileAvatar(
                  avatarId: controller.profileAvatarId,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _screens),
          if (badge != null)
            Positioned.fill(
              child: _BadgeCelebration(
                badge: badge,
                onDismiss: () => controller.markBadgeCelebrationSeen(badge.id),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: DesignTokens.navHeight,
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.creamLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                label: l10n.focus,
                icon: Icons.timer_outlined,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                label: l10n.room,
                icon: Icons.location_on_outlined,
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                label: l10n.stats,
                icon: Icons.bar_chart_rounded,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                label: l10n.sounds,
                icon: Icons.library_music_outlined,
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeCelebration extends StatelessWidget {
  const _BadgeCelebration({required this.badge, required this.onDismiss});

  final BadgeDefinition badge;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .52),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 720),
              curve: Curves.elasticOut,
              tween: Tween(begin: .25, end: 1),
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: badge.color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: badge.color.withValues(alpha: .46),
                      blurRadius: 48,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final position in const [
                      Alignment(-1, -.9),
                      Alignment(.85, -1),
                      Alignment(-.8, .75),
                      Alignment(.95, .65),
                    ])
                      Align(
                        alignment: position,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: badge.color.withValues(alpha: .62),
                          size: 22,
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.newBadge,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: badge.color,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 18),
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: badge.color.withValues(alpha: .18),
                          foregroundColor: badge.color,
                          child: Icon(badge.icon, size: 48),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.l10n.badgeName(badge),
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.badgeDescription(badge),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onDismiss,
                            child: Text(context.l10n.lovely),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 62,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foreground, size: 23),
                  const SizedBox(height: 3),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
