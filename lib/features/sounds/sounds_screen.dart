import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/atlas_sprite.dart';
import '../../core/models/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';
import '../../l10n/localization_extensions.dart';

class SoundsScreen extends StatelessWidget {
  const SoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final activeCount = controller.soundVolumes.values
        .where((value) => value > 0)
        .length;
    return SingleChildScrollView(
      key: const PageStorageKey('sounds-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Text(
                context.l10n.ambientSounds,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 48),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.soundsSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 34),
              ...soundCatalog.map(
                (sound) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SoundCard(
                    sound: sound,
                    available: controller.isSoundAvailable(sound.id),
                    volume: controller.soundVolumes[sound.id] ?? 0,
                    onToggle: () async {
                      final success = await controller.toggleSound(sound.id);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.audioErrorKind != null
                                  ? context.l10n.audioError(
                                      controller.audioErrorKind,
                                    )
                                  : context.l10n.soundComingSoon(sound.name),
                            ),
                          ),
                        );
                      }
                    },
                    onVolume: (value) =>
                        controller.setSoundVolume(sound.id, value),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CozyCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    activeCount == 0
                                        ? context.l10n.chooseSounds
                                        : context.l10n.activeSounds(
                                            activeCount,
                                          ),
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.terracotta,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            icon: const Icon(Icons.shuffle_rounded),
                            label: Text(context.l10n.activeMix(activeCount)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: activeCount == 0
                                ? null
                                : controller.stopAllSounds,
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: Text(context.l10n.stopAll),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creamLow,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.snooze_rounded,
                            color: AppColors.sage,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.l10n.sleepTimer,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.ink),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.sleepTimerMinutes,
                              dropdownColor: Theme.of(context).cardColor,
                              items:
                                  (controller.testMode
                                          ? const [1, 15, 30, 45, 60]
                                          : const [15, 30, 45, 60])
                                      .map(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            context.l10n.minutesShort(value),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.setSleepTimer(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: controller.sleepTimerActive
                          ? OutlinedButton.icon(
                              onPressed: controller.cancelSleepTimer,
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.timer_off_outlined),
                              label: Text(
                                context.l10n.cancelTimer(
                                  controller.sleepTimerLabel,
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: () async {
                                final started = await controller
                                    .startSleepTimer();
                                if (!started && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.playBeforeTimer,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.bedtime_outlined),
                              label: Text(context.l10n.startSleepTimer),
                            ),
                    ),
                    if (controller.sleepTimerJustFinished) ...[
                      const SizedBox(height: 9),
                      Text(
                        context.l10n.sleepTimerComplete,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.soundsInfo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.available,
    required this.volume,
    required this.onToggle,
    required this.onVolume,
  });

  final SoundItem sound;
  final bool available;
  final double volume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolume;

  @override
  Widget build(BuildContext context) {
    final active = available && volume > 0;
    return CozyCard(
      border: Border.all(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor,
        width: active ? 2 : 1,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 118,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _SoundPreview(sound: sound, active: active),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB0000000)],
                        stops: [.28, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Icon(sound.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            sound.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: active
                              ? context.l10n.pauseSound(sound.name)
                              : context.l10n.playSound(sound.name),
                          onPressed: available ? onToggle : null,
                          style: IconButton.styleFrom(
                            backgroundColor: active
                                ? AppColors.sageSoft
                                : Colors.white.withValues(alpha: .88),
                            foregroundColor: AppColors.ink,
                          ),
                          icon: Icon(
                            active
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    const Positioned(top: 12, right: 12, child: _PlayingBars()),
                  if (!available)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .58),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            context.l10n.comingSoon,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.volume_down_outlined, size: 18),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: available ? onVolume : null,
                  semanticFormatterCallback: (value) =>
                      context.l10n.percent((value * 100).round()),
                ),
              ),
              const Icon(Icons.volume_up_outlined, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoundPreview extends StatefulWidget {
  const _SoundPreview({required this.sound, required this.active});

  final SoundItem sound;
  final bool active;

  @override
  State<_SoundPreview> createState() => _SoundPreviewState();
}

class _SoundPreviewState extends State<_SoundPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _SoundPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.animateBack(0, duration: const Duration(milliseconds: 350));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: 1.055 + _controller.value * .045,
        child: child,
      ),
      child: AtlasSprite(
        assetPath: AppAssets.atmospherePreviewAtlas,
        columns: 2,
        rows: 3,
        column: widget.sound.previewColumn,
        row: widget.sound.previewRow,
        contentRect: widget.sound.previewCrop,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _PlayingBars extends StatefulWidget {
  const _PlayingBars();

  @override
  State<_PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<_PlayingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final wave = math.sin(
                (_controller.value * math.pi * 2) + index * 1.7,
              );
              return Container(
                width: 3,
                height: 7 + (wave + 1) * 4,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
