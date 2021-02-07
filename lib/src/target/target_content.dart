import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/content/custom_content_position.dart';

enum ContentAlign { top, bottom, left, right, custom }

class TargetContent {
  TargetContent({
    this.align = ContentAlign.bottom,
    this.child,
    this.customPosition,
  }) : assert(child != null && !(align == ContentAlign.custom && customPosition == null));

  final ContentAlign align;
  final CustomContentPosition customPosition;
  final Widget child;
  @override
  String toString() {
    return 'ContentTarget{align: $align, child: $child}';
  }
}
