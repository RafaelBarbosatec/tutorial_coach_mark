import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';

// ignore: constant_identifier_names
enum ShapeLightFocus { Circle, RRect }

TargetPosition? getTargetCurrent(
  TargetFocus target, {
  bool rootOverlay = false,
}) {
  if (target.keyTarget != null) {
    var key = target.keyTarget!;

    try {
      final RenderBox renderBoxRed =
          key.currentContext!.findRenderObject() as RenderBox;
      final size = renderBoxRed.size;

      BuildContext? context;
      if (rootOverlay) {
        context = key.currentContext!
            .findRootAncestorStateOfType<OverlayState>()
            ?.context;
      } else {
        context = key.currentContext!
            .findAncestorStateOfType<NavigatorState>()
            ?.context;
      }
      Offset offset;
      if (context != null) {
        offset = renderBoxRed.localToGlobal(
          Offset.zero,
          ancestor: context.findRenderObject(),
        );
      } else {
        offset = renderBoxRed.localToGlobal(Offset.zero);
      }

      return TargetPosition(size, offset);
    } catch (e) {
      throw NotFoundTargetException(target.identify);
    }
  } else {
    return target.targetPosition;
  }
}

abstract class TutorialCoachMarkController {
  void next();
  void previous();
  void skip();
}

extension StateExt on State {
  void safeSetState(VoidCallback call) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(call);
    }
  }
}

class NotFoundTargetException extends FormatException {
  NotFoundTargetException(identify)
      : super('It was not possible to obtain target position ($identify).');
}

void postFrame(VoidCallback callback) {
  Future.delayed(Duration.zero, callback);
}

extension NullableExt<T> on T? {
  void let(Function(T it) callback) {
    if (this != null) {
      callback(this as T);
    }
  }
}
