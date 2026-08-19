import 'package:flutter/material.dart';

import '../../core/models/focus_ritual.dart';
import '../../core/models/sound_item.dart';
import '../../core/services/app_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/cozy_card.dart';
import '../../l10n/localization_extensions.dart';

class FocusRitualCard extends StatelessWidget {
  const FocusRitualCard({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ritual = controller.selectedFocusRitual;
    final enabled = controller.canEditFocusRituals;
    final sounds =
        ritual?.soundVolumes.keys
            .map(_soundById)
            .whereType<SoundItem>()
            .toList() ??
        const <SoundItem>[];
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.manageRituals,
      child: InkWell(
        key: const Key('focus-ritual-card'),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        onTap: enabled
            ? () => showFocusRitualManager(context, controller)
            : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.ritualLocked)),
              ),
        child: CozyCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .32),
          ),
          child: Row(
            children: [
              _SoundscapeOrbit(sounds: sounds),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.focusRitual,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: .7,
                                ),
                          ),
                        ),
                        Icon(
                          enabled
                              ? Icons.tune_rounded
                              : Icons.lock_outline_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ritual == null
                          ? context.l10n.defaultFocus
                          : context.l10n.focusRitualName(ritual),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ritual == null
                          ? context.l10n.defaultFocusDescription
                          : context.l10n.formatRitualTimeSummary(
                              focusMinutes: ritual.focusMinutes,
                              breakMinutes: ritual.breakMinutes,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class _SoundscapeOrbit extends StatelessWidget {
  const _SoundscapeOrbit({required this.sounds});

  final List<SoundItem> sounds;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: .12),
              border: Border.all(color: primary.withValues(alpha: .28)),
            ),
            child: Icon(Icons.self_improvement_rounded, color: primary),
          ),
          for (var index = 0; index < sounds.length && index < 2; index++)
            Positioned(
              right: index == 0 ? 0 : null,
              left: index == 1 ? 0 : null,
              top: index == 0 ? 2 : null,
              bottom: index == 1 ? 2 : null,
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: primary.withValues(alpha: .45)),
                ),
                child: Icon(sounds[index].icon, size: 14, color: primary),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showFocusRitualManager(
  BuildContext context,
  AppController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (context) => _RitualManagerSheet(controller: controller),
);

class _RitualManagerSheet extends StatelessWidget {
  const _RitualManagerSheet({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => FractionallySizedBox(
        heightFactor: .82,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.manageRituals,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.cancel,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _RitualTile(
                    selected: controller.focusRituals.selectedRitualId == null,
                    title: context.l10n.defaultFocus,
                    subtitle: context.l10n.defaultFocusDescription,
                    sounds: const [],
                    onSelect: () => controller.selectFocusRitual(null),
                  ),
                  const SizedBox(height: 10),
                  for (final ritual in controller.focusRituals.rituals) ...[
                    _RitualTile(
                      selected:
                          controller.focusRituals.selectedRitualId == ritual.id,
                      title: context.l10n.focusRitualName(ritual),
                      subtitle: context.l10n.formatRitualTimeSummary(
                        focusMinutes: ritual.focusMinutes,
                        breakMinutes: ritual.breakMinutes,
                      ),
                      sounds: ritual.soundVolumes.keys
                          .map(_soundById)
                          .whereType<SoundItem>()
                          .toList(),
                      onSelect: () => controller.selectFocusRitual(ritual.id),
                      onEdit: () => _showRitualEditor(
                        context,
                        controller,
                        ritual: ritual,
                      ),
                      onDelete: () =>
                          _confirmDelete(context, controller, ritual),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 4),
                  FilledButton.tonalIcon(
                    key: const Key('new-focus-ritual'),
                    onPressed: controller.focusRituals.rituals.length < 5
                        ? () => _showRitualEditor(context, controller)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.l10n.newRitual),
                  ),
                  if (controller.focusRituals.rituals.length >= 5) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.maxFiveRituals,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RitualTile extends StatelessWidget {
  const _RitualTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.sounds,
    required this.onSelect,
    this.onEdit,
    this.onDelete,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final List<SoundItem> sounds;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: selected
          ? primary.withValues(alpha: .13)
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 13, 8, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: .65)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? primary : Theme.of(context).hintColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (sounds.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 7,
                        runSpacing: 4,
                        children: [
                          for (final sound in sounds)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(sound.icon, size: 15, color: primary),
                                const SizedBox(width: 3),
                                Text(
                                  sound.name,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit!();
                    if (value == 'delete') onDelete!();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(context.l10n.editRitual),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delete_outline_rounded),
                        title: Text(context.l10n.deleteRitual),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  AppController controller,
  FocusRitual ritual,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        context.l10n.deleteRitualQuestion(context.l10n.focusRitualName(ritual)),
      ),
      content: Text(context.l10n.deleteRitualBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.deleteRitual),
        ),
      ],
    ),
  );
  if (confirmed ?? false) await controller.deleteFocusRitual(ritual.id);
}

Future<void> _showRitualEditor(
  BuildContext context,
  AppController controller, {
  FocusRitual? ritual,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (context) => _RitualEditor(controller: controller, ritual: ritual),
);

class _RitualEditor extends StatefulWidget {
  const _RitualEditor({required this.controller, this.ritual});

  final AppController controller;
  final FocusRitual? ritual;

  @override
  State<_RitualEditor> createState() => _RitualEditorState();
}

class _RitualEditorState extends State<_RitualEditor> {
  late final TextEditingController _nameController;
  late int _focusMinutes;
  late int _breakMinutes;
  late Map<String, double> _soundVolumes;
  String? _nameError;
  bool _saving = false;

  static final _availableSounds = soundCatalog
      .where((sound) => focusRitualSoundIds.contains(sound.id))
      .toList();

  @override
  void initState() {
    super.initState();
    final ritual = widget.ritual;
    _focusMinutes = ritual?.focusMinutes ?? 25;
    _breakMinutes = ritual?.breakMinutes ?? 5;
    _soundVolumes = {...?ritual?.soundVolumes};
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nameController.text.isEmpty && widget.ritual != null) {
      _nameController.text = context.l10n.focusRitualName(widget.ritual!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: .92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.ritual == null
                          ? context.l10n.createRitual
                          : context.l10n.editRitual,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.cancel,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  TextField(
                    key: const Key('ritual-name-field'),
                    controller: _nameController,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.ritualName,
                      errorText: _nameError,
                      prefixIcon: const Icon(Icons.auto_awesome_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ChoiceSection(
                    title: context.l10n.focusDuration,
                    children: [
                      for (final minutes in focusRitualFocusOptions)
                        ChoiceChip(
                          label: Text(context.l10n.formatDuration(minutes)),
                          selected: _focusMinutes == minutes,
                          onSelected: (_) =>
                              setState(() => _focusMinutes = minutes),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ChoiceSection(
                    title: context.l10n.breakDuration,
                    children: [
                      for (final minutes in focusRitualBreakOptions)
                        ChoiceChip(
                          label: Text(context.l10n.formatDuration(minutes)),
                          selected: _breakMinutes == minutes,
                          onSelected: (_) =>
                              setState(() => _breakMinutes = minutes),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    context.l10n.ambienceMix,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.chooseUpToTwoSounds,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final sound in _availableSounds)
                    _SoundVolumeTile(
                      sound: sound,
                      selected: _soundVolumes.containsKey(sound.id),
                      value: _soundVolumes[sound.id] ?? .5,
                      onToggle: () => _toggleSound(sound.id),
                      onChanged: (value) =>
                          setState(() => _soundVolumes[sound.id] = value),
                    ),
                  if (_soundVolumes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        context.l10n.silentRitual,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      key: const Key('save-focus-ritual'),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(context.l10n.saveRitual),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSound(String id) {
    if (_soundVolumes.containsKey(id)) {
      setState(() => _soundVolumes.remove(id));
      return;
    }
    if (_soundVolumes.length >= 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.maxTwoSounds)));
      return;
    }
    setState(() => _soundVolumes[id] = .5);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > 30) {
      setState(() {
        _nameError = name.isEmpty
            ? context.l10n.ritualNameRequired
            : context.l10n.ritualNameTooLong;
      });
      return;
    }
    setState(() {
      _saving = true;
      _nameError = null;
    });
    final original = widget.ritual;
    final localizedTemplateName = original == null
        ? null
        : context.l10n.focusRitualName(
            original.copyWith(clearCustomName: true),
          );
    final ritual = FocusRitual(
      id: original?.id ?? 'ritual-${DateTime.now().microsecondsSinceEpoch}',
      templateKey: original?.templateKey,
      customName: original?.templateKey != null && name == localizedTemplateName
          ? null
          : name,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      soundVolumes: Map.unmodifiable(_soundVolumes),
    );
    try {
      await widget.controller.upsertFocusRitual(ritual);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 9),
      Wrap(spacing: 8, runSpacing: 8, children: children),
    ],
  );
}

class _SoundVolumeTile extends StatelessWidget {
  const _SoundVolumeTile({
    required this.sound,
    required this.selected,
    required this.value,
    required this.onToggle,
    required this.onChanged,
  });

  final SoundItem sound;
  final bool selected;
  final double value;
  final VoidCallback onToggle;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: selected ? primary.withValues(alpha: .10) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? primary.withValues(alpha: .45)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                Icon(sound.icon, color: selected ? primary : null),
                const SizedBox(width: 10),
                Expanded(child: Text(sound.name)),
                Checkbox(value: selected, onChanged: (_) => onToggle()),
              ],
            ),
          ),
          if (selected)
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: .1,
                    max: 1,
                    divisions: 9,
                    onChanged: onChanged,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(value * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

SoundItem? _soundById(String id) {
  for (final sound in soundCatalog) {
    if (sound.id == id) return sound;
  }
  return null;
}
