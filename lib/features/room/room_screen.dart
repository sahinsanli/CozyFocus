import 'package:flutter/material.dart';

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
                aspectRatio: .72,
                child: _RoomCanvas(
                  selectedIds: controller.selectedDecorationIds,
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
  const _RoomCanvas({required this.selectedIds});

  final Set<String> selectedIds;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5E7), Color(0xFFF2D2B7)],
        ),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
            child: CustomPaint(painter: _FloorPainter()),
          ),
          Positioned(
            left: 20,
            top: 24,
            child: Container(
              width: 94,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .55),
                border: Border.all(color: Colors.white, width: 7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wb_sunny_outlined,
                size: 38,
                color: Color(0xFFD59F65),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 60,
            child: Container(
              width: 74,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFB98760).withValues(alpha: .38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shelves, size: 44, color: AppColors.sage),
            ),
          ),
          if (selectedIds.contains('armchair'))
            const Positioned(
              left: 52,
              bottom: 86,
              child: Text('🪑', style: TextStyle(fontSize: 78)),
            ),
          if (selectedIds.contains('bookshelf'))
            const Positioned(
              right: 35,
              top: 103,
              child: Text('📚', style: TextStyle(fontSize: 42)),
            ),
          if (selectedIds.contains('cactus'))
            const Positioned(
              left: 52,
              top: 155,
              child: Text('🌵', style: TextStyle(fontSize: 58)),
            ),
          if (selectedIds.contains('hanging_plant'))
            const Positioned(
              right: 100,
              top: 20,
              child: Text('🌿', style: TextStyle(fontSize: 54)),
            ),
          if (selectedIds.contains('sleeping_cat'))
            const Positioned(
              right: 44,
              bottom: 36,
              child: Text('🐈', style: TextStyle(fontSize: 58)),
            ),
          Positioned(
            left: 26,
            right: 26,
            bottom: 22,
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .48),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: Text(
              'ROOM ART PLACEHOLDER',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.sage.withValues(alpha: .65),
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9986D).withValues(alpha: .26)
      ..strokeWidth = 1;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9C49F),
    );
    for (double y = 12; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 18; x < size.width; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x + 28, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final DecorationItem item;
  final bool unlocked;
  final bool selected;
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
                        ? Text(item.emoji, style: const TextStyle(fontSize: 48))
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
