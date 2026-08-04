import 'package:flutter/material.dart';

abstract final class DesignTokens {
  static const pagePadding = 20.0;
  static const sectionGap = 40.0;
  static const cardRadius = 28.0;
  static const smallRadius = 18.0;
  static const navHeight = 82.0;

  static const softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x12000000), blurRadius: 28, offset: Offset(0, 12)),
  ];
}
