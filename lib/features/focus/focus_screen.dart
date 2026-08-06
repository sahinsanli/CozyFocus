import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/atlas_sprite.dart';
import '../../core/services/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';

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
                          ? 'Preview complete!'
                          : 'Beautiful work!'
                    : 'Ready to focus?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.showCelebration
                    ? controller.testPreviewActive
                          ? 'This is exactly what a completed focus session looks like.'
                          : 'Your sanctuary grew a little calmer.'
                    : 'Settle in and give one thing your full attention.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 250,
                height: 250,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: DesignTokens.softShadow,
                  ),
                  child: Image.asset(
                    AppAssets.focusRoomHero,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, .38),
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (controller.showCelebration)
                _CelebrationCard(controller: controller)
              else ...[
                _TimerRing(
                  progress: controller.timerProgress,
                  time: time,
                  status: controller.timerStatus,
                  testPreview: controller.testPreviewActive,
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
                  label: const Text('Reset timer'),
                ),
                const SizedBox(height: 22),
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

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.time,
    required this.status,
    required this.testPreview,
  });

  final double progress;
  final String time;
  final FocusTimerStatus status;
  final bool testPreview;

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
                : 'Preview focus checkpoints, rewards, badges, and every room item.',
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
            'Preview sessions do not change your real statistics.',
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
                const _PlantGrowthCelebration(),
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
                  controller.testPreviewActive
                      ? 'Preview only — your real focus statistics were not changed.'
                      : 'Reward: a little more life for your cozy room 🌿',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: controller.resetTimer,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('Begin another session'),
                ),
              ],
            ),
          ),
        ],
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
