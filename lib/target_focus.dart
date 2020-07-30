import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class TargetFocus {
  TargetFocus({
    this.identify,
    this.keyTarget,
    this.targetPosition,
    this.contents,
    this.shape,
    this.radius,
    this.color,
    this.enableOverlayTab = false,
    this.enableTargetTab = true,
  }) : assert(keyTarget != null || targetPosition != null);

  final dynamic identify;
  final GlobalKey keyTarget;
  final TargetPosition targetPosition;
  final List<ContentTarget> contents;
  final ShapeLightFocus shape;
  final double radius;
  final bool enableOverlayTab;
  final bool enableTargetTab;
  final Color color;

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents, shape: $shape}';
  }
}
