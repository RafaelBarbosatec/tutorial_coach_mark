import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class TargetFocus{

  final GlobalKey keyTarget;
  final TargetPosition targetPosition;
  final List<ContentTarget> contents;

  TargetFocus({this.keyTarget, this.targetPosition, this.contents}):assert(keyTarget != null || targetPosition != null);

}