import 'dart:async';

import 'package:flutter/material.dart';

/// Adds one soft click to genuine taps while ignoring scrolls and drags.
class TapSoundRegion extends StatefulWidget {
  const TapSoundRegion({required this.onTap, required this.child, super.key});

  final Future<void> Function() onTap;
  final Widget child;

  @override
  State<TapSoundRegion> createState() => _TapSoundRegionState();
}

class _TapSoundRegionState extends State<TapSoundRegion> {
  Offset? _downPosition;
  int? _pointer;
  DateTime? _downAt;

  void _handleDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _downPosition = event.position;
    _downAt = DateTime.now();
  }

  void _handleUp(PointerUpEvent event) {
    if (_pointer != event.pointer) return;
    final distance =
        (event.position - (_downPosition ?? event.position)).distance;
    final duration = DateTime.now().difference(_downAt ?? DateTime.now());
    _clearPointer();
    if (distance <= 14 && duration <= const Duration(milliseconds: 750)) {
      unawaited(widget.onTap());
    }
  }

  void _handleCancel(PointerCancelEvent event) {
    if (_pointer == event.pointer) _clearPointer();
  }

  void _clearPointer() {
    _pointer = null;
    _downPosition = null;
    _downAt = null;
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _handleDown,
    onPointerUp: _handleUp,
    onPointerCancel: _handleCancel,
    child: widget.child,
  );
}
