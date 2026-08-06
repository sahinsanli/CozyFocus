import 'dart:math' as math;

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
    final activeItems = {
      for (final item in decorationCatalog)
        item.id: controller.isRoomItemActive(item.id),
    };
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
                          'Build your sanctuary, one focus at a time.',
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 17,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Auto-saved',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 899 / 1748,
                child: RepaintBoundary(
                  key: const Key('room-canvas'),
                  child: _RoomCanvas(
                    selectedIds: controller.selectedDecorationIds.where((id) {
                      final item = decorationCatalog.firstWhere(
                        (item) => item.id == id,
                      );
                      return controller.isDecorationUnlocked(item);
                    }).toSet(),
                    positions: controller.decorationPositions,
                    activeItems: activeItems,
                    onMoved: controller.moveDecoration,
                    onPlaced:
                        ({required id, required position, required slotId}) =>
                            controller.placeDecoration(
                              id: id,
                              position: position,
                              slotId: slotId,
                            ),
                    onInteraction: controller.toggleRoomItemInteraction,
                  ),
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
                        '${controller.unlockedDecorationCount}/${decorationCatalog.length} available',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Drag placed items between the glowing compatible slots.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .76,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: decorationCatalog.length,
                itemBuilder: (context, index) {
                  final item = decorationCatalog[index];
                  final unlocked = controller.isDecorationUnlocked(item);
                  final selected =
                      unlocked &&
                      controller.selectedDecorationIds.contains(item.id);
                  return _InventoryCard(
                    index: index,
                    item: item,
                    unlocked: unlocked,
                    selected: selected,
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

typedef _PlacementCallback =
    Future<void> Function({
      required String id,
      required Offset position,
      required String slotId,
    });

class _RoomSlot {
  const _RoomSlot(this.id, this.type, this.position);

  final String id;
  final RoomSlotType type;
  final Offset position;
}

const _roomSlots = <_RoomSlot>[
  _RoomSlot('floor_back_left', RoomSlotType.floor, Offset(-.34, .04)),
  _RoomSlot('floor_back_right', RoomSlotType.floor, Offset(.44, -.02)),
  _RoomSlot('floor_middle_left', RoomSlotType.floor, Offset(-.18, .29)),
  _RoomSlot('floor_middle_right', RoomSlotType.floor, Offset(.47, .24)),
  _RoomSlot('floor_front_center', RoomSlotType.floor, Offset(.02, .62)),
  _RoomSlot('floor_front_right', RoomSlotType.floor, Offset(.43, .58)),
  _RoomSlot('wall_left', RoomSlotType.wall, Offset(-.38, -.52)),
  _RoomSlot('wall_right', RoomSlotType.wall, Offset(.43, -.56)),
  _RoomSlot('ceiling_left', RoomSlotType.ceiling, Offset(-.52, -.56)),
  _RoomSlot('ceiling_right', RoomSlotType.ceiling, Offset(.62, -.55)),
  _RoomSlot('table_left', RoomSlotType.tabletop, Offset(-.42, -.04)),
  _RoomSlot('table_right', RoomSlotType.tabletop, Offset(-.07, .00)),
];

class _RoomCanvas extends StatefulWidget {
  const _RoomCanvas({
    required this.selectedIds,
    required this.positions,
    required this.activeItems,
    required this.onMoved,
    required this.onPlaced,
    required this.onInteraction,
  });

  final Set<String> selectedIds;
  final Map<String, Offset> positions;
  final Map<String, bool> activeItems;
  final void Function(String id, Offset position) onMoved;
  final _PlacementCallback onPlaced;
  final Future<void> Function(String id) onInteraction;

  @override
  State<_RoomCanvas> createState() => _RoomCanvasState();
}

class _RoomCanvasState extends State<_RoomCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _atmosphere;
  RoomSlotType? _dragType;

  @override
  void initState() {
    super.initState();
    _atmosphere = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
      value: .25,
    );
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (!bindingName.contains('TestWidgetsFlutterBinding')) {
      _atmosphere.repeat();
    }
  }

  @override
  void dispose() {
    _atmosphere.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items =
        decorationCatalog
            .where((item) => widget.selectedIds.contains(item.id))
            .toList()
          ..sort((a, b) => a.layer.index.compareTo(b.layer.index));
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: DesignTokens.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = constraints.biggest;
          return AnimatedBuilder(
            animation: _atmosphere,
            builder: (context, _) {
              final wave = math.sin(_atmosphere.value * math.pi * 2);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.emptyRoomBaseV2,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CurtainSwayPainter(_atmosphere.value),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Opacity(
                      opacity: .10 + (wave + 1) * .025,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-1, -.85),
                            end: const Alignment(.45, .45),
                            colors: [
                              const Color(0xFF8BB7E5),
                              const Color(0xFFBFD7F2).withValues(alpha: .42),
                              Colors.transparent,
                            ],
                            stops: const [0, .36, .72],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _FireflyPainter(_atmosphere.value),
                      ),
                    ),
                  ),
                  if (_dragType != null)
                    for (final slot in _roomSlots.where(
                      (slot) => slot.type == _dragType,
                    ))
                      Align(
                        alignment: Alignment(
                          slot.position.dx,
                          slot.position.dy,
                        ),
                        child: Container(
                          width: canvasSize.width * .16,
                          height: canvasSize.width * .10,
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: .18),
                            border: Border.all(
                              color: AppColors.sageSoft,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sageSoft.withValues(
                                  alpha: .36,
                                ),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                  for (final item in items)
                    _RoomSprite(
                      key: ValueKey(item.id),
                      item: item,
                      position:
                          widget.positions[item.id] ?? item.defaultPosition,
                      canvasSize: canvasSize,
                      atmosphere: _atmosphere.value,
                      active: widget.activeItems[item.id] ?? false,
                      onMoved: (position) => widget.onMoved(item.id, position),
                      onDragState: (dragging) => setState(
                        () => _dragType = dragging ? item.slotType : null,
                      ),
                      onPlaced: (position) {
                        final slot = _nearestSlot(item.slotType, position);
                        return widget.onPlaced(
                          id: item.id,
                          position: slot.position,
                          slotId: slot.id,
                        );
                      },
                      onInteraction: () => widget.onInteraction(item.id),
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
                              'Drag to snap  •  Tap lights to switch on',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  _RoomSlot _nearestSlot(RoomSlotType type, Offset position) {
    final compatible = _roomSlots.where((slot) => slot.type == type).toList();
    compatible.sort((a, b) {
      final aDistance = (a.position - position).distanceSquared;
      final bDistance = (b.position - position).distanceSquared;
      return aDistance.compareTo(bDistance);
    });
    return compatible.first;
  }
}

class _RoomSprite extends StatefulWidget {
  const _RoomSprite({
    super.key,
    required this.item,
    required this.position,
    required this.canvasSize,
    required this.atmosphere,
    required this.active,
    required this.onMoved,
    required this.onDragState,
    required this.onPlaced,
    required this.onInteraction,
  });

  final DecorationItem item;
  final Offset position;
  final Size canvasSize;
  final double atmosphere;
  final bool active;
  final ValueChanged<Offset> onMoved;
  final ValueChanged<bool> onDragState;
  final Future<void> Function(Offset position) onPlaced;
  final Future<void> Function() onInteraction;

  @override
  State<_RoomSprite> createState() => _RoomSpriteState();
}

class _RoomSpriteState extends State<_RoomSprite> {
  late Offset _dragPosition = widget.position;
  bool _dragging = false;

  @override
  void didUpdateWidget(covariant _RoomSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.position != widget.position) {
      _dragPosition = widget.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final phase = math.sin(widget.atmosphere * math.pi * 2);
    final isSwaying = item.id == 'hanging_plant' || item.id == 'potted_plant';
    final isCat = item.id == 'sleeping_cat';
    Widget sprite = Stack(
      fit: StackFit.expand,
      children: [
        if (item.slotType == RoomSlotType.floor && item.id != 'rug')
          Align(
            alignment: const Alignment(0, .82),
            child: FractionallySizedBox(
              widthFactor: .66,
              heightFactor: .09,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .16),
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(100, 28),
                  ),
                ),
              ),
            ),
          ),
        AnimatedOpacity(
          opacity: widget.active ? .72 : 0,
          duration: const Duration(milliseconds: 350),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD779).withValues(alpha: .72),
                  const Color(0xFFFFD779).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
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
    );
    if (isSwaying) {
      sprite = Transform.rotate(
        angle: phase * (item.id == 'hanging_plant' ? .025 : .009),
        alignment: item.id == 'hanging_plant'
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: sprite,
      );
    } else if (isCat) {
      sprite = Transform.scale(
        scaleX: 1,
        scaleY: 1 + (phase + 1) * .008,
        alignment: Alignment.bottomCenter,
        child: sprite,
      );
    }

    return Align(
      alignment: Alignment(_dragPosition.dx, _dragPosition.dy),
      child: FractionallySizedBox(
        widthFactor: item.widthFactor,
        child: Semantics(
          button: true,
          label: item.isInteractive
              ? '${item.name}, drag to move or tap to switch ${widget.active ? 'off' : 'on'}'
              : '${item.name}, drag to move',
          child: GestureDetector(
            key: Key('room-decoration-${item.id}'),
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) {
              _dragging = true;
              _dragPosition = widget.position;
              HapticFeedback.selectionClick();
              widget.onDragState(true);
            },
            onPanUpdate: (details) {
              setState(() {
                _dragPosition = Offset(
                  _dragPosition.dx +
                      details.delta.dx / (widget.canvasSize.width / 2),
                  _dragPosition.dy +
                      details.delta.dy / (widget.canvasSize.height / 2),
                );
              });
              widget.onMoved(_dragPosition);
            },
            onPanEnd: (_) async {
              _dragging = false;
              widget.onDragState(false);
              await widget.onPlaced(_dragPosition);
            },
            onPanCancel: () {
              _dragging = false;
              widget.onDragState(false);
            },
            onTap: item.isInteractive ? widget.onInteraction : null,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              tween: Tween(begin: .78, end: 1),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
              child: AspectRatio(aspectRatio: 1, child: sprite),
            ),
          ),
        ),
      ),
    );
  }
}

class _FireflyPainter extends CustomPainter {
  const _FireflyPainter(this.progress);

  final double progress;

  static const _points = <Offset>[
    Offset(.13, .18),
    Offset(.29, .24),
    Offset(.38, .34),
    Offset(.20, .38),
    Offset(.46, .29),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * .52, size.height * .42));
    final leafPaint = Paint()
      ..color = const Color(0xFF43604D).withValues(alpha: .25);
    for (var index = 0; index < 4; index++) {
      final phase = progress * math.pi * 2 + index * .9;
      final center = Offset(
        size.width * (.10 + index * .09),
        size.height * (.08 + (index.isEven ? .025 : .075)),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(math.sin(phase) * .20 - .35);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * .038,
          height: size.width * .018,
        ),
        leafPaint,
      );
      canvas.restore();
    }
    for (var index = 0; index < _points.length; index++) {
      final point = _points[index];
      final phase = progress * math.pi * 2 + index * 1.31;
      final center = Offset(
        point.dx * size.width + math.sin(phase) * 5,
        point.dy * size.height + math.cos(phase * .8) * 8,
      );
      final alpha = (.42 + (math.sin(phase * 1.4) + 1) * .22).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        7,
        Paint()..color = const Color(0xFFFFE98C).withValues(alpha: alpha * .18),
      );
      canvas.drawCircle(
        center,
        2.1,
        Paint()..color = const Color(0xFFFFF4B5).withValues(alpha: alpha),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CurtainSwayPainter extends CustomPainter {
  const _CurtainSwayPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(progress * math.pi * 2) * size.width * .006;
    final paint = Paint()
      ..color = const Color(0xFFFFF4DE).withValues(alpha: .13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .018
      ..strokeCap = StrokeCap.round;
    final right = Path()
      ..moveTo(size.width * .445, size.height * .04)
      ..cubicTo(
        size.width * .43 + sway,
        size.height * .15,
        size.width * .45 - sway,
        size.height * .28,
        size.width * .425,
        size.height * .38,
      );
    final left = Path()
      ..moveTo(size.width * .018, size.height * .03)
      ..cubicTo(
        size.width * .006 - sway,
        size.height * .13,
        size.width * .018 + sway,
        size.height * .25,
        size.width * .014,
        size.height * .36,
      );
    canvas.drawPath(right, paint);
    canvas.drawPath(left, paint);
  }

  @override
  bool shouldRepaint(covariant _CurtainSwayPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.index,
    required this.item,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final DecorationItem item;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      padding: const EdgeInsets.all(14),
      border: Border.all(
        width: selected ? 2 : 1,
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor,
      ),
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.creamLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : .40,
                      child: ColorFiltered(
                        colorFilter: unlocked
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.dst,
                              )
                            : const ColorFilter.mode(
                                Color(0xFF777777),
                                BlendMode.saturation,
                              ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: AtlasSprite(
                            assetPath: item.assetPath,
                            columns: item.atlasColumns,
                            rows: item.atlasRows,
                            column: item.atlasColumn,
                            row: item.atlasRow,
                            contentRect: item.atlasCrop,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .54),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!unlocked)
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${item.unlockMinutes} min',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
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
    );
  }
}
