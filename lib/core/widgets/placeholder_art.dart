import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PlaceholderArt extends StatelessWidget {
  const PlaceholderArt({
    required this.icon,
    this.emoji,
    this.label,
    this.circular = false,
    super.key,
  });

  final IconData icon;
  final String? emoji;
  final String? label;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 18,
          bottom: 20,
          child: Container(
            width: 72,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        Positioned(
          right: 22,
          top: 22,
          child: Icon(
            icon,
            size: 54,
            color: AppColors.sage.withValues(alpha: .2),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji ?? '☕', style: const TextStyle(fontSize: 58)),
            if (label != null) ...[
              const SizedBox(height: 8),
              Text(
                label!,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.sage),
              ),
            ],
          ],
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1DE), Color(0xFFF2D7C8), Color(0xFFDCE6D4)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circular ? 999 : 30),
        child: content,
      ),
    );
  }
}
