import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/design_tokens.dart';
import 'core/widgets/app_scope.dart';
import 'features/focus/focus_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/room/room_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/sounds/sounds_screen.dart';
import 'features/stats/stats_screen.dart';

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
          tooltip: 'Settings',
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        title: Text(
          'Cozy Focus Room',
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
              label: 'Open profile',
              child: InkWell(
                key: const Key('profile-button'),
                onTap: _openProfile,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.sageSoft,
                  foregroundColor: AppColors.sage,
                  child: Text(
                    controller.username.characters.first.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
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
                label: 'Focus',
                icon: Icons.timer_outlined,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                label: 'Room',
                icon: Icons.location_on_outlined,
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                label: 'Stats',
                icon: Icons.bar_chart_rounded,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                label: 'Sounds',
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
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontSize: 12,
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
