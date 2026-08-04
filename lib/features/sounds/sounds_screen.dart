import 'package:flutter/material.dart';

import '../../core/models/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';

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
                'Ambient\nSounds',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 48),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Mix your perfect background noise.',
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
                    volume: controller.soundVolumes[sound.id] ?? 0,
                    onToggle: () => controller.toggleSound(sound.id),
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
                                        ? 'Choose sounds to create a mix.'
                                        : '$activeCount sounds are in your active mix.',
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
                            label: Text('Mix ($activeCount)'),
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
                            label: const Text('Stop All'),
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
                              'Sleep Timer',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.ink),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.sleepTimerMinutes,
                              dropdownColor: Theme.of(context).cardColor,
                              items: const [15, 30, 45, 60]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text('$value min'),
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
                    const SizedBox(height: 10),
                    Text(
                      'Audio files are not bundled yet. Mixer controls are a safe functional mock.',
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
    required this.volume,
    required this.onToggle,
    required this.onVolume,
  });

  final SoundItem sound;
  final double volume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolume;

  @override
  Widget build(BuildContext context) {
    final active = volume > 0;
    return CozyCard(
      border: Border.all(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor,
        width: active ? 2 : 1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.sageMid : AppColors.beige,
                ),
                child: Icon(
                  sound.icon,
                  color: active ? Colors.white : AppColors.mutedInk,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  sound.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: active ? 'Pause ${sound.name}' : 'Play ${sound.name}',
                onPressed: onToggle,
                style: IconButton.styleFrom(
                  backgroundColor: active
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: active
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                icon: Icon(
                  active ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.volume_down_outlined, size: 18),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: onVolume,
                  semanticFormatterCallback: (value) =>
                      '${(value * 100).round()} percent',
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
