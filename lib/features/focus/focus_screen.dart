import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/services/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../../core/widgets/placeholder_art.dart';

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
                    ? 'Beautiful work!'
                    : 'Ready to focus?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.showCelebration
                    ? 'Your sanctuary grew a little calmer.'
                    : 'Settle in and give one thing your full attention.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 250,
                height: 190,
                child: PlaceholderArt(
                  icon: Icons.menu_book_outlined,
                  emoji: '🌱',
                  label: 'Focus nook placeholder',
                  circular: true,
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
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: controller.startOrToggleTimer,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: const StadiumBorder(),
                      textStyle: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    icon: Icon(_primaryIcon(controller.timerStatus)),
                    label: Text(_primaryLabel(controller.timerStatus)),
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
  });

  final double progress;
  final String time;
  final FocusTimerStatus status;

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
                  status == FocusTimerStatus.running
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
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.terracotta,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  'Session complete',
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
                const Text('Reward: a little more life for your cozy room 🌿'),
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
