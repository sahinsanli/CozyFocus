import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class CozyCard extends StatelessWidget {
  const CozyCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            color ??
            (dark
                ? Theme.of(context).cardColor
                : Colors.white.withValues(alpha: .84)),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        border:
            border ??
            Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: .65),
            ),
        boxShadow: DesignTokens.softShadow,
      ),
      child: child,
    );
  }
}
