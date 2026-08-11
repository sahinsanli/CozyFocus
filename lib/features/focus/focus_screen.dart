import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/atlas_sprite.dart';
import '../../core/models/app_progress.dart';
import '../../core/models/decoration_item.dart';
import '../../core/services/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../settings/settings_screen.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final minutes = controller.remainingSeconds ~/ 60;
    final seconds = controller.remainingSeconds % 60;
    final time =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      key: const PageStorageKey('focus-scroll'),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.pagePadding,
        24,
        DesignTokens.pagePadding,
        36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              Text(
                controller.showCelebration
                    ? controller.testPreviewActive
                          ? 'Test focus complete!'
                          : 'Beautiful work!'
                    : controller.isBreakSession
                    ? 'Time to breathe'
                    : 'Ready to focus?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.showCelebration
                    ? controller.testPreviewActive
                          ? 'Fast-forwarded time used the real progression rules.'
                          : 'Your sanctuary grew a little calmer.'
                    : controller.isBreakSession
                    ? 'Your focus is safe. Take a gentle pause.'
                    : 'Settle in and give one thing your full attention.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _CraftPreview(controller: controller),
              const SizedBox(height: 32),
              if (controller.showCelebration)
                _CelebrationCard(controller: controller)
              else ...[
                _TimerRing(
                  progress: controller.timerProgress,
                  time: time,
                  status: controller.timerStatus,
                  testPreview: controller.testPreviewActive,
                  isBreak: controller.isBreakSession,
                ),
                if (controller.testMode) ...[
                  const SizedBox(height: 18),
                  _TestModePanel(controller: controller),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: controller.testMode
                        ? controller.completeTestFocus
                        : controller.startOrToggleTimer,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: const StadiumBorder(),
                      textStyle: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    icon: Icon(
                      controller.testMode
                          ? Icons.fast_forward_rounded
                          : _primaryIcon(controller.timerStatus),
                    ),
                    label: Text(
                      controller.testMode
                          ? 'Complete focus now'
                          : _primaryLabel(controller.timerStatus),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: controller.timerStatus == FocusTimerStatus.idle
                      ? null
                      : controller.resetTimer,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    controller.isBreakSession ? 'End break' : 'Reset timer',
                  ),
                ),
                if (!controller.testMode &&
                    !controller.isBreakSession &&
                    controller.timerStatus == FocusTimerStatus.idle)
                  TextButton.icon(
                    onPressed: controller.startBreak,
                    icon: const Icon(Icons.coffee_outlined),
                    label: Text(
                      'Take a ${controller.shortBreakMinutes} min break',
                    ),
                  ),
                const SizedBox(height: 22),
                if (controller.focusReminders &&
                    controller.todayMinutes == 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sageSoft.withValues(alpha: .26),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.notifications_active_outlined),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'A gentle reminder: one small focus session is enough to begin.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (!controller.hasCloudAccount) ...[
                  _AccountProtectionCard(controller: controller),
                  const SizedBox(height: 14),
                ],
                CozyCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sageSoft,
                        ),
                        child: const Icon(
                          Icons.flag_outlined,
                          color: AppColors.sage,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today’s gentle goal',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${controller.formatMinutes(controller.todayMinutes)} of '
                              '${controller.formatMinutes(controller.dailyGoalMinutes)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${((controller.todayMinutes / controller.dailyGoalMinutes) * 100).clamp(0, 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static IconData _primaryIcon(FocusTimerStatus status) => switch (status) {
    FocusTimerStatus.running => Icons.pause_rounded,
    FocusTimerStatus.paused => Icons.play_arrow_rounded,
    _ => Icons.play_arrow_rounded,
  };

  static String _primaryLabel(FocusTimerStatus status) => switch (status) {
    FocusTimerStatus.running => 'Pause',
    FocusTimerStatus.paused => 'Resume',
    _ => 'Start focus',
  };
}

class _AccountProtectionCard extends StatelessWidget {
  const _AccountProtectionCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      key: const Key('focus-account-prompt'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .14),
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep your progress safe',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guest progress stays on this device. Sign in to keep your focus history, rewards, and room after a reinstall or device change.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('focus-open-account'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AccountScreen(),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(
              controller.accountFeaturesAvailable
                  ? 'Protect my progress'
                  : 'Open account settings',
            ),
          ),
        ],
      ),
    );
  }
}

class _CraftPreview extends StatelessWidget {
  const _CraftPreview({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final item = controller.previewCraftItem;
    if (item == null) {
      return CozyCard(
        child: Column(
          children: [
            Icon(
              Icons.home_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'Your sanctuary collection is complete',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final stage = controller.previewCraftVisualStage;
    final shownMinutes = controller.previewCraftMinutes;
    return SizedBox(
      width: 300,
      child: CozyCard(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          children: [
            SizedBox(
              width: 240,
              height: 205,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: .86, end: 1.0).animate(animation),
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                ),
                child: SizedBox.expand(
                  key: ValueKey('${item.id}-$stage'),
                  child: AtlasSprite(
                    assetPath: item.craftAssetPath,
                    columns: 5,
                    rows: item.craftAtlasRows,
                    column: stage,
                    row: item.craftAtlasRow,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crafting ${item.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.previewCraftRatio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 7),
            Text(
              '$shownMinutes / ${item.unlockMinutes} focused minutes • stage ${stage + 1}/5',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.time,
    required this.status,
    required this.testPreview,
    required this.isBreak,
  });

  final double progress;
  final String time;
  final FocusTimerStatus status;
  final bool testPreview;
  final bool isBreak;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Focus timer $time',
      value: '${(progress * 100).round()} percent complete',
      child: SizedBox(
        width: 276,
        height: 276,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress == 0 ? .006 : progress,
                strokeWidth: 13,
                strokeCap: StrokeCap.round,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .13),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                boxShadow: DesignTokens.softShadow,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  testPreview
                      ? 'TEST PREVIEW'
                      : isBreak
                      ? status == FocusTimerStatus.paused
                            ? 'BREAK PAUSED'
                            : 'SHORT BREAK'
                      : status == FocusTimerStatus.running
                      ? 'FOCUSING'
                      : status == FocusTimerStatus.paused
                      ? 'PAUSED'
                      : 'FOCUS SESSION',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestModePanel extends StatelessWidget {
  const _TestModePanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      color: AppColors.terracottaSoft.withValues(alpha: .35),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.terracotta),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Test Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch.adaptive(
                value: controller.testMode,
                onChanged: controller.setTestMode,
              ),
            ],
          ),
          Text(
            controller.testPreviewActive
                ? '${controller.testElapsedMinutes} of ${controller.activeSessionMinutes} minutes previewed'
                : 'Fast-forward focus time while keeping the real production, claim, badge, and inventory rules.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.advanceTestFocus(5),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const FittedBox(child: Text('Advance 5 min')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.advanceTestFocus(10),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const FittedBox(child: Text('Advance 10 min')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completed test sessions are saved exactly like normal focus sessions.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.terracotta,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final reward = controller.nextPendingReward;
    final hasReward = reward != null;
    return CozyCard(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).cardColor
          : AppColors.creamLow,
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _Confetti())),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                _RewardPreview(controller: controller, reward: reward),
                const SizedBox(height: 12),
                Text(
                  controller.testPreviewActive
                      ? 'Test session complete'
                      : 'Session complete',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '+${controller.lastRewardMinutes} focus minutes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward == null
                      ? 'Your focus minutes were saved. Keep going to finish the current item.'
                      : reward.kind == PendingRewardKind.craftedItem
                      ? '${decorationCatalog.firstWhere((item) => item.id == reward.itemId).name} is ready to claim.'
                      : '${dailyDecorationCatalog.firstWhere((item) => item.id == reward.itemId).name} came from today’s gentle goal.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                if (reward != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => controller.claimNextReward(place: true),
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      icon: Icon(Icons.add_home_work_outlined),
                      label: Text('Claim & Place'),
                    ),
                  ),
                  if (hasReward) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => controller.claimNextReward(place: false),
                      child: const Text('Claim for later'),
                    ),
                  ],
                  if (controller.pendingRewards.length > 1)
                    Text(
                      '${controller.pendingRewards.length - 1} more reward${controller.pendingRewards.length == 2 ? '' : 's'} waiting',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                ] else
                  FilledButton(
                    onPressed: controller.continueAfterCelebration,
                    style: FilledButton.styleFrom(shape: const StadiumBorder()),
                    child: Text(
                      controller.isBreakSession
                          ? 'Continue break'
                          : 'Begin another session',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({required this.controller, required this.reward});

  final AppController controller;
  final PendingReward? reward;

  @override
  Widget build(BuildContext context) {
    Widget sprite;
    final pending = reward;
    if (pending?.kind == PendingRewardKind.craftedItem) {
      final item = decorationCatalog.firstWhere(
        (item) => item.id == pending!.itemId,
      );
      sprite = AtlasSprite(
        assetPath: item.assetPath,
        columns: item.atlasColumns,
        rows: item.atlasRows,
        column: item.atlasColumn,
        row: item.atlasRow,
        contentRect: item.atlasCrop,
        fit: BoxFit.contain,
      );
    } else if (pending?.kind == PendingRewardKind.dailyDecoration) {
      final item = dailyDecorationCatalog.firstWhere(
        (item) => item.id == pending!.itemId,
      );
      sprite = AtlasSprite(
        assetPath: item.assetPath,
        columns: 1,
        rows: 1,
        column: item.atlasColumn,
        row: item.atlasRow,
        contentRect: item.atlasCrop,
        fit: BoxFit.contain,
      );
    } else {
      sprite = const Icon(Icons.auto_awesome_rounded, size: 82);
    }
    return SizedBox(
      width: 170,
      height: 170,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 720),
        curve: Curves.elasticOut,
        tween: Tween(begin: .35, end: 1),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageSoft.withValues(alpha: .32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sageMid.withValues(alpha: .30),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
        child: sprite,
      ),
    );
  }
}

class _PlantGrowthCelebration extends StatefulWidget {
  const _PlantGrowthCelebration();

  @override
  State<_PlantGrowthCelebration> createState() =>
      _PlantGrowthCelebrationState();
}

class _PlantGrowthCelebrationState extends State<_PlantGrowthCelebration> {
  int _stage = 0;
  Timer? _growthTimer;

  @override
  void initState() {
    super.initState();
    _growthTimer = Timer.periodic(const Duration(milliseconds: 720), (timer) {
      if (!mounted || _stage == 2) {
        timer.cancel();
        return;
      }
      setState(() => _stage++);
    });
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      height: 154,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: AtlasSprite(
              assetPath: AppAssets.focusCelebrationAtlas,
              columns: 2,
              rows: 2,
              column: 0,
              row: 0,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageSoft.withValues(alpha: .34),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sageMid.withValues(alpha: .28),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 680),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: .55, end: 1.0).animate(animation),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
            child: SizedBox(
              key: ValueKey(_stage),
              width: 150,
              height: 150,
              child: AtlasSprite(
                assetPath: AppAssets.plantGrowthAtlas,
                columns: 3,
                rows: 3,
                column: _stage,
                row: 0,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter());
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [AppColors.sage, AppColors.terracotta, Color(0xFFD8B46C)];
    final random = math.Random(18);
    for (var i = 0; i < 28; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: .48);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        2 + random.nextDouble() * 3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
