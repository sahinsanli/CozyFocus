import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/decoration_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final upcoming = decorationCatalog
        .where((item) => item.unlockMinutes > controller.allTimeMinutes)
        .toList();
    final nextTarget = upcoming.isEmpty
        ? controller.allTimeMinutes
        : upcoming.first.unlockMinutes;
    final progress = nextTarget == 0
        ? 1.0
        : (controller.allTimeMinutes / nextTarget).clamp(0.0, 1.0);

    return SingleChildScrollView(
      key: const PageStorageKey('stats-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Text(
                'Your Journey',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Take a moment to reflect on your progress.\nEvery focused minute builds a calmer you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              CozyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.auto_awesome,
                      title: 'Focus Summary',
                    ),
                    const SizedBox(height: 18),
                    _SummaryTile(
                      label: 'TODAY',
                      value: controller.formatMinutes(controller.todayMinutes),
                      note:
                          controller.todayMinutes >= controller.dailyGoalMinutes
                          ? 'Daily goal complete'
                          : '${controller.dailyGoalMinutes - controller.todayMinutes} min to your goal',
                      tint: AppColors.creamLow,
                    ),
                    const SizedBox(height: 12),
                    _SummaryTile(
                      label: 'WEEKLY',
                      value: controller.formatMinutes(controller.weeklyMinutes),
                      note: 'Your current rhythm',
                      tint: AppColors.blush,
                    ),
                    const SizedBox(height: 12),
                    _SummaryTile(
                      label: 'ALL TIME',
                      value: controller.formatMinutes(
                        controller.allTimeMinutes,
                      ),
                      note: controller.allTimeMinutes == 0
                          ? 'Your journey starts here'
                          : 'A growing focus practice',
                      tint: AppColors.sageSoft.withValues(alpha: .28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CozyCard(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).cardColor
                    : AppColors.terracottaSoft.withValues(alpha: .45),
                child: Column(
                  children: [
                    Text(
                      'Daily Streak',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.local_fire_department_outlined,
                      size: 56,
                      color: AppColors.terracotta,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.streakDays}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.terracotta,
                      ),
                    ),
                    Text(
                      'DAYS IN A ROW',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(letterSpacing: 1.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CozyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.bar_chart_rounded,
                      title: 'This Week’s Rhythm',
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: _WeeklyChart(
                        values: controller.currentWeekMinutes,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CozyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.flag_outlined,
                      title: 'Milestones',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.creamLow,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  upcoming.isEmpty
                                      ? 'Sanctuary Keeper'
                                      : upcoming.first.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.ink),
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppColors.sage),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            borderRadius: BorderRadius.circular(9),
                            color: AppColors.sage,
                            backgroundColor: AppColors.beige,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              upcoming.isEmpty
                                  ? 'Every room reward is unlocked.'
                                  : '${upcoming.first.unlockMinutes - controller.allTimeMinutes} focused minutes to unlock',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedInk),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'UPCOMING UNLOCKS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (upcoming.isEmpty)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(Icons.done_all_rounded),
                        ),
                        title: Text('All decorations unlocked'),
                      )
                    else
                      ...upcoming
                          .take(3)
                          .map(
                            (item) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.beige,
                                child: Icon(item.icon, color: AppColors.sage),
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.unlockMinutes} focus minutes',
                              ),
                              trailing: const Icon(
                                Icons.lock_outline,
                                size: 20,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.note,
    required this.tint,
  });

  final String label;
  final String value;
  final String note;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        border: Border.all(color: AppColors.beige),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.sage,
              fontSize: 38,
            ),
          ),
          Text(
            note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxValue = math.max(30, values.fold(0, math.max));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final ratio = values[index] / maxValue;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                values[index] == 0 ? '' : '${values[index]}m',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 14 + 80 * ratio,
                width: 22,
                decoration: BoxDecoration(
                  color: ratio == 0
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : (index == DateTime.now().weekday - 1
                            ? AppColors.terracotta
                            : AppColors.sageMid),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        );
      }),
    );
  }
}
