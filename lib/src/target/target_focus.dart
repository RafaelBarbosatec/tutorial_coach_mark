import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

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
    this.alignSkip,
    this.paddingFocus,
    this.focusAnimationDuration,
    this.pulseVariation,
    this.targetBounds
  }) : assert(keyTarget != null || targetPosition != null || targetBounds != null);

  final dynamic identify;
  final GlobalKey? keyTarget;
  final TargetPosition? targetPosition;
  final List<TargetContent>? contents;
  final ShapeLightFocus? shape;
  final double? radius;
  final bool enableOverlayTab;
  final bool enableTargetTab;
  final Color? color;
  final AlignmentGeometry? alignSkip;
  final double? paddingFocus;
  final Duration? focusAnimationDuration;
  final Tween<double>? pulseVariation;
  final Stream<Rect> targetBounds;

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents, shape: $shape}';
  }
}
