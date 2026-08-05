import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets/app_assets.dart';
import '../../core/assets/atlas_sprite.dart';
import '../../core/models/decoration_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_scope.dart';
import '../../core/widgets/cozy_card.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return SingleChildScrollView(
      key: const PageStorageKey('room-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Room Decoration',
                            maxLines: 1,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your sanctuary.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      await controller.saveLayout();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your cozy layout is saved.'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      controller.layoutSaved ? 'Saved' : 'Save Layout',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              AspectRatio(
                aspectRatio: 899 / 1748,
                child: _RoomCanvas(
                  selectedIds: controller.selectedDecorationIds,
                  positions: controller.decorationPositions,
                  focusMinutes: controller.allTimeMinutes,
                  onMoved: controller.moveDecoration,
                ),
              ),
              const SizedBox(height: DesignTokens.sectionGap),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Inventory',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${controller.unlockedDecorationCount}/${decorationCatalog.length} unlocked',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .78,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: decorationCatalog.length,
                itemBuilder: (context, index) {
                  final item = decorationCatalog[index];
                  final unlocked =
                      controller.allTimeMinutes >= item.unlockMinutes;
                  final selected = controller.selectedDecorationIds.contains(
                    item.id,
                  );
                  return _InventoryCard(
                    item: item,
                    unlocked: unlocked,
                    selected: selected,
                    focusMinutes: controller.allTimeMinutes,
                    onTap: () => controller.toggleDecoration(item.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCanvas extends StatelessWidget {
  const _RoomCanvas({
    required this.selectedIds,
    required this.positions,
    required this.focusMinutes,
    required this.onMoved,
  });

  final Set<String> selectedIds;
  final Map<String, Offset> positions;
  final int focusMinutes;
  final void Function(String id, Offset position) onMoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: DesignTokens.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = constraints.biggest;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppAssets.sanctuaryRoom,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              for (final placement in const [
                ('armchair', .34),
                ('bookshelf', .25),
                ('cactus', .34),
                ('hanging_plant', .24),
                ('sleeping_cat', .25),
              ])
                if (selectedIds.contains(placement.$1))
                  _RoomSprite(
                    key: ValueKey(placement.$1),
                    decorationId: placement.$1,
                    position: positions[placement.$1] ?? const Offset(0, 0),
                    widthFactor: placement.$2,
                    canvasSize: canvasSize,
                    plantStage: _plantStage(focusMinutes),
                    onMoved: (position) => onMoved(placement.$1, position),
                  ),
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .48),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        child: Text(
                          'Drag to arrange  •  Tap Moonleaf to grow',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static int _plantStage(int minutes) => minutes >= 180
      ? 2
      : minutes >= 60
      ? 1
      : 0;
}

class _RoomSprite extends StatefulWidget {
  const _RoomSprite({
    super.key,
    required this.decorationId,
    required this.position,
    required this.widthFactor,
    required this.canvasSize,
    required this.plantStage,
    required this.onMoved,
  });

  final String decorationId;
  final Offset position;
  final double widthFactor;
  final Size canvasSize;
  final int plantStage;
  final ValueChanged<Offset> onMoved;

  @override
  State<_RoomSprite> createState() => _RoomSpriteState();
}

class _RoomSpriteState extends State<_RoomSprite> {
  late int _shownPlantStage = widget.plantStage;

  @override
  void didUpdateWidget(covariant _RoomSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plantStage != widget.plantStage) {
      _shownPlantStage = widget.plantStage;
    }
  }

  void _move(DragUpdateDetails details) {
    final next = Offset(
      widget.position.dx + details.delta.dx / (widget.canvasSize.width / 2),
      widget.position.dy + details.delta.dy / (widget.canvasSize.height / 2),
    );
    widget.onMoved(next);
  }

  void _handleTap() {
    if (widget.decorationId != 'cactus') return;
    HapticFeedback.selectionClick();
    setState(() => _shownPlantStage = (_shownPlantStage + 1) % 3);
  }

  @override
  Widget build(BuildContext context) {
    final item = decorationCatalog.firstWhere(
      (item) => item.id == widget.decorationId,
    );
    final isPlant = widget.decorationId == 'cactus';
    return Align(
      alignment: Alignment(widget.position.dx, widget.position.dy),
      child: FractionallySizedBox(
        widthFactor: widget.widthFactor,
        child: Semantics(
          button: true,
          label: isPlant
              ? 'Moonleaf, drag to move or tap to preview growth'
              : '${item.name}, drag to move',
          child: GestureDetector(
            key: Key('room-decoration-${widget.decorationId}'),
            behavior: HitTestBehavior.translucent,
            onPanUpdate: _move,
            onTap: _handleTap,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              tween: Tween(begin: .78, end: 1),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
              child: AspectRatio(
                aspectRatio: isPlant ? 1 : item.contentAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.decorationId != 'hanging_plant')
                      Align(
                        alignment: const Alignment(0, .92),
                        child: FractionallySizedBox(
                          widthFactor: .68,
                          heightFactor: .10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .18),
                              borderRadius: const BorderRadius.all(
                                Radius.elliptical(100, 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isPlant)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween(
                              begin: .62,
                              end: 1.0,
                            ).animate(animation),
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                        ),
                        child: SizedBox.expand(
                          key: ValueKey(_shownPlantStage),
                          child: AtlasSprite(
                            assetPath: AppAssets.plantGrowthAtlas,
                            columns: 3,
                            rows: 3,
                            column: _shownPlantStage,
                            row: 0,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      )
                    else
                      AtlasSprite(
                        assetPath: item.assetPath,
                        columns: item.atlasColumns,
                        rows: item.atlasRows,
                        column: item.atlasColumn,
                        row: item.atlasRow,
                        contentRect: item.atlasCrop,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.unlocked,
    required this.selected,
    required this.focusMinutes,
    required this.onTap,
  });

  final DecorationItem item;
  final bool unlocked;
  final bool selected;
  final int focusMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : .55,
      child: CozyCard(
        padding: const EdgeInsets.all(14),
        border: Border.all(
          width: selected ? 2 : 1,
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.creamLow
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: unlocked
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: AtlasSprite(
                              assetPath: item.assetPath,
                              columns: item.atlasColumns,
                              rows: item.atlasRows,
                              column: item.id == 'cactus'
                                  ? _RoomCanvas._plantStage(focusMinutes)
                                  : item.atlasColumn,
                              row: item.atlasRow,
                              contentRect: item.atlasCrop,
                              fit: BoxFit.contain,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.unlockMinutes} min',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'to unlock',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.sage,
                    ),
                ],
              ),
              Text(item.category, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
