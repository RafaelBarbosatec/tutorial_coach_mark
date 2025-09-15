import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';

/// Defines the shape of the focus highlight around target widgets.
enum ShapeLightFocus {
  /// Circular highlight shape
// ignore: constant_identifier_names
  Circle,

  /// Rounded rectangle highlight shape
// ignore: constant_identifier_names
  RRect
}

/// Gets the current position and size of a target widget.
///
/// This function calculates the actual position and size of a target widget
/// on the screen, handling both [GlobalKey] based targets and custom [TargetPosition].
///
/// Parameters:
/// - [target]: The [TargetFocus] to get position for
/// - [rootOverlay]: Whether to use root overlay for coordinate calculation
///
/// Returns the [TargetPosition] or null if the target cannot be found.
/// Throws [NotFoundTargetException] if the target widget is not found.
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

/// Abstract controller interface for tutorial coach mark interactions.
///
/// This controller provides methods to programmatically control the tutorial
/// flow from within content builders or external code.
///
/// Available through [TargetContentBuilder] callback function.
abstract class TutorialCoachMarkController {
  /// Advances to the next step in the tutorial.
  void next();

  /// Goes back to the previous step in the tutorial.
  void previous();

  /// Skips the entire tutorial.
  void skip();
}

/// Extension on [State] to provide safe state updates.
extension StateExt on State {
  /// Safely calls [setState] only if the widget is still mounted.
  ///
  /// This prevents errors when trying to update state after the widget
  /// has been disposed or removed from the widget tree.
  void safeSetState(VoidCallback call) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(call);
    }
  }
}

/// Exception thrown when a target widget cannot be found or positioned.
///
/// This typically occurs when:
/// - The [GlobalKey] is not attached to any widget
/// - The target widget is not currently in the widget tree
/// - The widget's render object is not available
class NotFoundTargetException extends FormatException {
  NotFoundTargetException(identify)
      : super('It was not possible to obtain target position ($identify).');
}

/// Schedules a callback to run after the current frame.
///
/// This is useful for deferring operations until after the widget tree
/// has been built and painted. Commonly used for initialization tasks
/// that require the widget to be fully rendered.
void postFrame(VoidCallback callback) {
  Future.delayed(Duration.zero, callback);
}

/// Extension on nullable types to provide safe callback execution.
extension NullableExt<T> on T? {
  /// Executes the callback only if the value is not null.
  ///
  /// This is similar to Kotlin's `let` function and provides a safe way
  /// to perform operations on nullable values.
  ///
  /// Example:
  /// ```dart
  /// String? maybeText = getText();
  /// maybeText.let((text) => print(text)); // Only prints if text is not null
  /// ```
  void let(Function(T it) callback) {
    if (this != null) {
      callback(this as T);
    }
  }
}
