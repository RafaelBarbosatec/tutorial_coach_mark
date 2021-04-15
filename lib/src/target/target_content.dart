import 'package:flutter/widgets.dart';

class CustomTargetContentPosition {
  CustomTargetContentPosition({
    this.top,
    this.left,
    this.bottom,
  });
  final double? top, left, bottom;
  @override
  String toString() {
    return 'CustomTargetPosition{top: $top, left: $left, bottom: $bottom}';
  }
}

enum ContentAlign { top, bottom, left, right, custom }

class TargetContent {
  TargetContent({
    this.align = ContentAlign.bottom,
    required this.child,
    this.customPosition,
  }) : assert(!(align == ContentAlign.custom && customPosition == null));

  final ContentAlign align;
  final CustomTargetContentPosition? customPosition;
  final Widget child;
  @override
  String toString() {
    return 'ContentTarget{align: $align, child: $child}';
  }
}
