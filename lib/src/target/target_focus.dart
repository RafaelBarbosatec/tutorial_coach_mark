import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

/// Represents a widget that will be focused during the tutorial.
///
/// This class defines a target area in your app that should be highlighted
/// and focused during the tutorial sequence. Each [TargetFocus] can contain
/// multiple content pieces that will be displayed around the focused widget.
///
/// Example usage:
/// ```dart
/// TargetFocus(
///   identify: "menu_button",
///   keyTarget: menuButtonKey,
///   contents: [
///     TargetContent(
///       align: ContentAlign.bottom,
///       child: Text("This is the menu button"),
///     ),
///   ],
///   shape: ShapeLightFocus.RRect,
///   radius: 10.0,
/// )
/// ```
class TargetFocus {
  TargetFocus({
    this.identify,
    this.keyTarget,
    this.targetPosition,
    this.contents,
    this.shape,
    this.radius,
    this.borderSide,
    this.color,
    this.enableOverlayTab = false,
    this.enableTargetTab = true,
    this.alignSkip,
    this.paddingFocus,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseVariation,
  }) : assert(keyTarget != null || targetPosition != null);

  /// Free identifier for this target. Can be used to distinguish between targets.
  final dynamic identify;

  /// [GlobalKey] of the widget that should be focused.
  /// Either [keyTarget] or [targetPosition] must be provided.
  final GlobalKey? keyTarget;

  /// Custom position for the focus area instead of using [keyTarget].
  /// Either [keyTarget] or [targetPosition] must be provided.
  final TargetPosition? targetPosition;

  /// List of content pieces to display around the focused widget.
  /// Each content can be positioned relative to the target (top, bottom, left, right).
  final List<TargetContent>? contents;

  /// Shape of the focus highlight. Can be [ShapeLightFocus.Circle] or [ShapeLightFocus.RRect].
  final ShapeLightFocus? shape;

  /// Corner radius when [shape] is [ShapeLightFocus.RRect].
  final double? radius;

  /// Border configuration for the focus highlight.
  final BorderSide? borderSide;

  /// Enable tap anywhere on the screen overlay to proceed to next step.
  /// Default is `false`.
  final bool enableOverlayTab;

  /// Enable tap on the target widget to proceed to next step.
  /// Default is `true`.
  final bool enableTargetTab;

  /// Custom color for this target's focus highlight.
  final Color? color;

  /// Alignment of the skip button relative to this target.
  final AlignmentGeometry? alignSkip;

  /// Padding around the focus area. Overrides the global paddingFocus for this target.
  final double? paddingFocus;

  /// Duration of the focus animation for this target.
  /// Overrides the global focus animation duration.
  final Duration? focusAnimationDuration;

  /// Duration of the unfocus animation for this target.
  /// Overrides the global unfocus animation duration.
  final Duration? unFocusAnimationDuration;

  /// Custom pulse animation variation for this target.
  /// Defines the scale range for the pulse effect (e.g., Tween(begin: 1.0, end: 0.99)).
  final Tween<double>? pulseVariation;

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents, shape: $shape}';
  }
}
