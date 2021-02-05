import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

TargetPosition getTargetCurrent(TargetFocus target) {
  if (target.keyTarget != null) {
    var key = target.keyTarget;

    try {
      final RenderBox renderBoxRed = key.currentContext.findRenderObject();
      final size = renderBoxRed.size;
      final state = key.currentContext.findAncestorStateOfType<NavigatorState>();
      Offset offset;
      if (state != null) {
        offset = renderBoxRed.localToGlobal(Offset.zero, ancestor: state.context.findRenderObject());
      } else {
        offset = renderBoxRed.localToGlobal(Offset.zero);
      }

      return TargetPosition(size, offset);
    } catch (e) {
      print("TutorialCoachMark (ERROR): It was not possible to obtain target position.");
      return null;
    }
  } else {
    return target.targetPosition;
  }
}
