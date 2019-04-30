import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class TargetFocus{

  final dynamic identify;
  final GlobalKey keyTarget;
  final TargetPosition targetPosition;
  final List<ContentTarget> contents;

  TargetFocus(
      {
        this.identify,
        this.keyTarget,
        this.targetPosition,
        this.contents}):assert(keyTarget != null || targetPosition != null);

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents}';
  }

}