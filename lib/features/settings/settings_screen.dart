import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/account_service.dart';
import '../../core/services/app_controller.dart';
import '../../core/services/firebase_progress_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../../l10n/localization_extensions.dart';

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
            child: Text(context.l10n.done),
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
    final l10n = context.l10n;
    final dailyGoalValues = _withCurrent(const [
      60,
      90,
      120,
      180,
      240,
      360,
      480,
    ], controller.dailyGoalMinutes);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.appTitle,
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
                  l10n.settings,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 34),
                _SectionLabel(l10n.appSettings),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_outlined,
                        title: l10n.focusReminders,
                        subtitle: l10n.focusRemindersBody,
                        trailing: Switch(
                          value: controller.focusReminders,
                          onChanged: controller.setFocusReminders,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.flag_outlined,
                        title: l10n.dailyGoal,
                        subtitle: l10n.dailyGoalBody,
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: controller.dailyGoalMinutes,
                            items: dailyGoalValues
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(l10n.formatDuration(value)),
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
                        title: l10n.appearance,
                        subtitle: l10n.appearanceBody,
                        trailing: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text(l10n.light),
                            ),
                            ButtonSegment(value: true, label: Text(l10n.dark)),
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
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.language_rounded,
                        title: l10n.language,
                        subtitle: l10n.languageBody,
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            key: const Key('language-selector'),
                            value: controller.languageCode,
                            items: [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(l10n.english),
                              ),
                              DropdownMenuItem(
                                value: 'tr',
                                child: Text(l10n.turkish),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.setLanguageCode(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.sectionGap),
                _SectionLabel(l10n.focusOptions),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.timer_outlined,
                        title: l10n.defaultFocusDuration,
                        subtitle: l10n.defaultFocusDurationBody,
                        trailing: _MinutesDropdown(
                          value: controller.defaultFocusMinutes,
                          values: _withCurrent(const [
                            15,
                            25,
                            45,
                            60,
                            75,
                            90,
                          ], controller.defaultFocusMinutes),
                          onChanged: controller.setDefaultFocusMinutes,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.coffee_outlined,
                        title: l10n.shortBreakDuration,
                        subtitle: l10n.shortBreakDurationBody,
                        trailing: _MinutesDropdown(
                          value: controller.shortBreakMinutes,
                          values: _withCurrent(const [
                            5,
                            10,
                            15,
                          ], controller.shortBreakMinutes),
                          onChanged: controller.setShortBreakMinutes,
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingsRow(
                        icon: Icons.autorenew_rounded,
                        title: l10n.autoStartBreaks,
                        subtitle: l10n.autoStartBreaksBody(
                          controller.shortBreakMinutes,
                        ),
                        trailing: Switch(
                          value: controller.autoStartBreaks,
                          onChanged: controller.setAutoStartBreaks,
                        ),
                      ),
                      if (kDebugMode) ...[
                        const Divider(height: 1),
                        _SettingsRow(
                          icon: Icons.science_outlined,
                          title: l10n.testMode,
                          subtitle: l10n.testModeSettingsBody,
                          trailing: Switch(
                            value: controller.testMode,
                            onChanged: controller.setTestMode,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.sectionGap),
                _SectionLabel(l10n.accountAndSync),
                const SizedBox(height: 12),
                _AccountCard(controller: controller),
                const SizedBox(height: DesignTokens.sectionGap),
                _SectionLabel(l10n.supportSection),
                const SizedBox(height: 12),
                CozyCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _LinkRow(
                        icon: Icons.help_outline,
                        title: l10n.helpCenter,
                        onTap: () => _showInfo(
                          context,
                          l10n.helpCenter,
                          l10n.helpCenterBody,
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.info_outline,
                        title: l10n.aboutCozyFocus,
                        onTap: () => _showInfo(
                          context,
                          l10n.aboutCozyFocus,
                          l10n.aboutBody,
                        ),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.shield_outlined,
                        title: l10n.privacyPolicy,
                        onTap: () => _openPage('privacy'),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.description_outlined,
                        title: l10n.termsOfUse,
                        onTap: () => _openPage('terms'),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.person_remove_outlined,
                        title: l10n.accountDeletionInfo,
                        onTap: () => _openPage('delete-account'),
                      ),
                      const Divider(height: 1),
                      _LinkRow(
                        icon: Icons.support_agent_rounded,
                        title: l10n.support,
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l10n.accountSyncTitle),
      ),
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
                      ? context.l10n.sanctuaryProtected
                      : context.l10n.accountKeepProgress,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.hasCloudAccount
                      ? context.l10n.syncProtectedBody
                      : context.l10n.guestSyncBody,
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
    final l10n = context.l10n;
    final syncLabel = switch (controller.cloudSyncState) {
      CloudSyncState.localOnly => l10n.storedOnDevice,
      CloudSyncState.syncing => l10n.syncing,
      CloudSyncState.synced =>
        controller.lastSyncedAt == null
            ? l10n.cloudSyncActive
            : l10n.syncedAt(_clock(controller.lastSyncedAt!)),
      CloudSyncState.error => l10n.offlineSyncLater,
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
                          ? l10n.guestAccount
                          : account?.email ??
                                account?.displayName ??
                                l10n.cozyAccount,
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
                  tooltip: l10n.syncNow,
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
          if (controller.accountErrorKind != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.accountError(controller.accountErrorKind),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          if (isGuest) ...[
            if (!controller.accountFeaturesAvailable)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.accountUnavailable,
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
                      success: l10n.googleLinked,
                    ),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: Text(l10n.continueGoogle),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed:
                  controller.accountBusy || !controller.accountFeaturesAvailable
                  ? null
                  : () => _showEmailDialog(context, controller, create: true),
              icon: const Icon(Icons.alternate_email_rounded),
              label: Text(l10n.createEmailAccount),
            ),
            TextButton(
              onPressed:
                  controller.accountBusy || !controller.accountFeaturesAvailable
                  ? null
                  : () => _showEmailDialog(context, controller, create: false),
              child: Text(l10n.alreadyHaveAccount),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: controller.accountBusy
                  ? null
                  : () => _runAction(
                      context,
                      controller.signOut,
                      success: l10n.signedOut,
                    ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.logOut),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
              ),
              onPressed: controller.accountBusy
                  ? null
                  : () => _confirmDelete(context, controller),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.deleteAccountData),
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
  final l10n = context.l10n;
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final submit = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(create ? l10n.createAccount : l10n.emailSignIn),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.email),
              validator: (value) => value == null || !value.contains('@')
                  ? l10n.invalidEmail
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: password,
              obscureText: true,
              autofillHints: [
                create ? AutofillHints.newPassword : AutofillHints.password,
              ],
              decoration: InputDecoration(labelText: l10n.password),
              validator: (value) => value == null || value.length < 6
                  ? l10n.passwordSixChars
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
                          SnackBar(content: Text(l10n.resetEmailSent)),
                        );
                      }
                    } catch (_) {}
                  },
                  child: Text(l10n.forgotPassword),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogContext, true);
            }
          },
          child: Text(create ? l10n.create : l10n.signIn),
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
    success: create ? l10n.accountCreated : l10n.welcomeBack,
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  AppController controller,
) async {
  final l10n = context.l10n;
  final password = TextEditingController();
  final needsPassword = controller.account?.type == CozyAccountType.email;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteAccountQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.deleteAccountWarning),
          if (needsPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
          onPressed: () {
            if (needsPassword && password.text.isEmpty) {
              ScaffoldMessenger.of(
                dialogContext,
              ).showSnackBar(SnackBar(content: Text(l10n.enterPassword)));
              return;
            }
            Navigator.pop(dialogContext, true);
          },
          child: Text(l10n.deletePermanently),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await _runAction(
    context,
    () => controller.deleteAccount(password: password.text),
    success: l10n.accountDeleted,
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
        content: Text(context.l10n.accountError(controller.accountErrorKind)),
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
              (value) => DropdownMenuItem(
                value: value,
                child: Text(context.l10n.formatDuration(value)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

List<int> _withCurrent(List<int> standard, int current) {
  final values = {...standard, current}.toList()..sort();
  return values;
}
