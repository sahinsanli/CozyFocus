import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints one cell from an image atlas and optionally crops the transparent or
/// decorative padding inside that cell.
class AtlasSprite extends StatefulWidget {
  const AtlasSprite({
    required this.assetPath,
    required this.columns,
    required this.rows,
    required this.column,
    required this.row,
    this.contentRect = const Rect.fromLTWH(0, 0, 1, 1),
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.high,
    super.key,
  }) : assert(column >= 0 && column < columns),
       assert(row >= 0 && row < rows);

  final String assetPath;
  final int columns;
  final int rows;
  final int column;
  final int row;

  /// Normalized content bounds inside the selected cell.
  final Rect contentRect;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  @override
  State<AtlasSprite> createState() => _AtlasSpriteState();
}

class _AtlasSpriteState extends State<AtlasSprite> {
  ui.Image? _image;
  ImageStream? _stream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _image = info.image);
      },
      onError: (_, _) {
        if (!mounted) return;
        setState(() => _image = null);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant AtlasSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) _resolveImage();
  }

  void _resolveImage() {
    final next = AssetImage(
      widget.assetPath,
    ).resolve(createLocalImageConfiguration(context));
    if (next.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = next..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return const SizedBox.expand();
    return CustomPaint(
      painter: _AtlasPainter(
        image: image,
        columns: widget.columns,
        rows: widget.rows,
        column: widget.column,
        row: widget.row,
        contentRect: widget.contentRect,
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: widget.filterQuality,
      ),
    );
  }
}

class _AtlasPainter extends CustomPainter {
  const _AtlasPainter({
    required this.image,
    required this.columns,
    required this.rows,
    required this.column,
    required this.row,
    required this.contentRect,
    required this.fit,
    required this.alignment,
    required this.filterQuality,
  });

  final ui.Image image;
  final int columns;
  final int rows;
  final int column;
  final int row;
  final Rect contentRect;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = image.width / columns;
    final cellHeight = image.height / rows;
    final source = Rect.fromLTWH(
      (column + contentRect.left) * cellWidth,
      (row + contentRect.top) * cellHeight,
      contentRect.width * cellWidth,
      contentRect.height * cellHeight,
    );
    final fitted = applyBoxFit(fit, source.size, size);
    final sourceRect = alignment.inscribe(fitted.source, source);
    final destinationRect = alignment.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      sourceRect,
      destinationRect,
      Paint()
        ..isAntiAlias = true
        ..filterQuality = filterQuality,
    );
  }

  @override
  bool shouldRepaint(covariant _AtlasPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.column != column ||
      oldDelegate.row != row ||
      oldDelegate.contentRect != contentRect ||
      oldDelegate.fit != fit ||
      oldDelegate.alignment != alignment ||
      oldDelegate.filterQuality != filterQuality;
}
