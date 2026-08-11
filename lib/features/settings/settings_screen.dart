import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/account_service.dart';
import '../../core/services/app_controller.dart';
import '../../core/services/firebase_progress_repository.dart';
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

  Future<void> _openPage(String path) => launchUrl(
    Uri.parse('https://cozyfocus-1ca80.web.app/$path'),
    mode: LaunchMode.externalApplication,
  );

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
                        subtitle: 'Show a gentle nudge on the Focus screen',
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
                        subtitle:
                            'Start a ${controller.shortBreakMinutes} min break after focus ends',
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
                const _SectionLabel('ACCOUNT & SYNC'),
                const SizedBox(height: 12),
                _AccountCard(controller: controller),
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
                          'Cozy Focus works offline and securely syncs your progress when you connect a Google or email account.',
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.info_outline,
                        title: 'About Cozy Focus',
                        onTap: () => _showInfo(
                          context,
                          'About Cozy Focus',
                          'Cozy Focus • Version 1.0.0\nA calm, local-first productivity sanctuary.',
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _openPage('privacy'),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.support_agent_rounded,
                        title: 'Support',
                        onTap: () => _openPage('support'),
                      ),
                    ],
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

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Account & Sync')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  controller.hasCloudAccount
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_upload_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.hasCloudAccount
                      ? 'Your sanctuary is protected'
                      : 'Keep your progress safe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.hasCloudAccount
                      ? 'Your focus history, rewards, inventory, and room are synced with your account.'
                      : 'Guest progress stays on this device. Connect Google or create an email account so it survives a reinstall or device change.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                _AccountCard(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account;
    final isGuest = account?.isGuest ?? true;
    final syncLabel = switch (controller.cloudSyncState) {
      CloudSyncState.localOnly => 'Stored safely on this device',
      CloudSyncState.syncing => 'Syncing your sanctuary…',
      CloudSyncState.synced =>
        controller.lastSyncedAt == null
            ? 'Cloud sync is active'
            : 'Synced at ${_clock(controller.lastSyncedAt!)}',
      CloudSyncState.error => 'Offline — changes will sync later',
    };
    return CozyCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.creamLow,
                foregroundColor: AppColors.sage,
                child: Icon(
                  isGuest ? Icons.cloud_off_outlined : Icons.cloud_done,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? 'Guest account'
                          : account?.email ??
                                account?.displayName ??
                                'Cozy account',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      syncLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGuest)
                IconButton(
                  tooltip: 'Sync now',
                  onPressed: controller.accountBusy
                      ? null
                      : controller.syncAccountNow,
                  icon: const Icon(Icons.sync_rounded),
                ),
            ],
          ),
          if (controller.accountBusy) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
          if (controller.accountError != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.accountError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          if (isGuest) ...[
            if (!controller.accountFeaturesAvailable)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Account services are temporarily unavailable. Your progress remains on this device.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            FilledButton.icon(
              onPressed:
                  controller.accountBusy || !controller.accountFeaturesAvailable
                  ? null
                  : () => _runAction(
                      context,
                      controller.continueWithGoogle,
                      success: 'Your progress is now linked to Google.',
                    ),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed:
                  controller.accountBusy || !controller.accountFeaturesAvailable
                  ? null
                  : () => _showEmailDialog(context, controller, create: true),
              icon: const Icon(Icons.alternate_email_rounded),
              label: const Text('Create email account'),
            ),
            TextButton(
              onPressed:
                  controller.accountBusy || !controller.accountFeaturesAvailable
                  ? null
                  : () => _showEmailDialog(context, controller, create: false),
              child: const Text('I already have an account'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: controller.accountBusy
                  ? null
                  : () => _runAction(
                      context,
                      controller.signOut,
                      success: 'Signed out. A new guest space is ready.',
                    ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
              ),
              onPressed: controller.accountBusy
                  ? null
                  : () => _confirmDelete(context, controller),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete account and data'),
            ),
          ],
        ],
      ),
    );
  }

  static String _clock(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

Future<void> _showEmailDialog(
  BuildContext context,
  AppController controller, {
  required bool create,
}) async {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final submit = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(create ? 'Create account' : 'Email sign in'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value == null || !value.contains('@')
                  ? 'Enter a valid email.'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: password,
              obscureText: true,
              autofillHints: [
                create ? AutofillHints.newPassword : AutofillHints.password,
              ],
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => value == null || value.length < 6
                  ? 'Use at least 6 characters.'
                  : null,
            ),
            if (!create)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    if (email.text.trim().isEmpty) return;
                    try {
                      await controller.sendPasswordReset(email.text);
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent.'),
                          ),
                        );
                      }
                    } catch (_) {}
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogContext, true);
            }
          },
          child: Text(create ? 'Create' : 'Sign in'),
        ),
      ],
    ),
  );
  if (submit != true || !context.mounted) return;
  await _runAction(
    context,
    () => create
        ? controller.createEmailAccount(email.text, password.text)
        : controller.signInWithEmail(email.text, password.text),
    success: create
        ? 'Account created. Your progress is syncing.'
        : 'Welcome back. Your progress has been merged.',
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  AppController controller,
) async {
  final password = TextEditingController();
  final needsPassword = controller.account?.type == CozyAccountType.email;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This permanently deletes your cloud progress and account. This cannot be undone.',
          ),
          if (needsPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm your password',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
          onPressed: () {
            if (needsPassword && password.text.isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Enter your password.')),
              );
              return;
            }
            Navigator.pop(dialogContext, true);
          },
          child: const Text('Delete permanently'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await _runAction(
    context,
    () => controller.deleteAccount(password: password.text),
    success: 'Your account and cloud data were deleted.',
  );
}

Future<void> _runAction(
  BuildContext context,
  Future<void> Function() action, {
  required String success,
}) async {
  try {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(success)));
  } catch (_) {
    if (!context.mounted) return;
    final controller = AppScope.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.accountError ?? 'The account action failed.'),
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
