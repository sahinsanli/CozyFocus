import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showInfo(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cozy Focus Room',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your cozy experience.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 34),
                const _SectionLabel('APP SETTINGS'),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_outlined,
                        title: 'Focus Reminders',
                        subtitle: 'Gentle nudges to start your sessions',
                        trailing: Switch(
                          value: controller.focusReminders,
                          onChanged: controller.setFocusReminders,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.flag_outlined,
                        title: 'Daily Goal',
                        subtitle: 'Set your focus target',
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: controller.dailyGoalMinutes,
                            items: const [60, 90, 120, 180]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value < 60
                                          ? '$value min'
                                          : '${value ~/ 60}${value % 60 == 0 ? ' h' : '.5 h'}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) controller.setDailyGoal(value);
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: 'Light or Dark mode',
                        trailing: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: false, label: Text('Light')),
                            ButtonSegment(value: true, label: Text('Dark')),
                          ],
                          selected: {controller.darkMode},
                          onSelectionChanged: (values) =>
                              controller.setDarkMode(values.first),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            textStyle: WidgetStatePropertyAll(
                              Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.sectionGap),
                const _SectionLabel('FOCUS OPTIONS'),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.timer_outlined,
                        title: 'Default Focus Duration',
                        subtitle: 'Used for new focus sessions',
                        trailing: _MinutesDropdown(
                          value: controller.defaultFocusMinutes,
                          values: const [15, 25, 45, 60],
                          onChanged: controller.setDefaultFocusMinutes,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.coffee_outlined,
                        title: 'Short Break Duration',
                        subtitle: 'Time to gently recharge',
                        trailing: _MinutesDropdown(
                          value: controller.shortBreakMinutes,
                          values: const [5, 10, 15],
                          onChanged: controller.setShortBreakMinutes,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.autorenew_rounded,
                        title: 'Auto-start Breaks',
                        subtitle: 'Begin breaks after focus ends',
                        trailing: Switch(
                          value: controller.autoStartBreaks,
                          onChanged: controller.setAutoStartBreaks,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.science_outlined,
                        title: 'Test Mode',
                        subtitle: 'Preview timers, rewards, and unlocks',
                        trailing: Switch(
                          value: controller.testMode,
                          onChanged: controller.setTestMode,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.sectionGap),
                const _SectionLabel('SUPPORT'),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _LinkRow(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () => _showInfo(
                          context,
                          'Help Center',
                          'Cozy Focus is an offline-first prototype. Start a timer, build focus minutes, and use them to unlock your room.',
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.info_outline,
                        title: 'About Cozy Focus',
                        onTap: () => _showInfo(
                          context,
                          'About Cozy Focus',
                          'Cozy Focus MVP • Version 1.0.0\nA calm, local-first productivity sanctuary.',
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _showInfo(
                          context,
                          'Privacy Policy',
                          'This prototype stores preferences and progress only on this device. It does not include accounts, analytics, or cloud sync.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showInfo(
                      context,
                      'Mock account action',
                      'There is no account or backend in this MVP, so there is nothing to log out from.',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.terracotta,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.creamLow,
            foregroundColor: AppColors.sage,
            child: Icon(icon, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.arrow_forward_rounded),
      onTap: onTap,
    );
  }
}

class _MinutesDropdown extends StatelessWidget {
  const _MinutesDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final int value;
  final List<int> values;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        items: values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text('$value min')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
