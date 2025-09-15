import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../tutorial_coach_mark.dart';

/// Defines custom positioning for tutorial content when using [ContentAlign.custom].
///
/// Use this class to specify exact positioning of content relative to the screen edges.
/// At least one positioning parameter must be provided.
///
/// Example:
/// ```dart
/// CustomTargetContentPosition(
///   top: 100.0,
///   left: 50.0,
/// )
/// ```
class CustomTargetContentPosition {
  CustomTargetContentPosition({
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  /// Distance from the top edge of the screen.
  final double? top;

  /// Distance from the left edge of the screen.
  final double? left;

  /// Distance from the right edge of the screen.
  final double? right;

  /// Distance from the bottom edge of the screen.
  final double? bottom;

  @override
  String toString() {
    return 'CustomTargetPosition{top: $top, left: $left, right: $right, bottom: $bottom}';
  }
}

/// Defines where the content should be positioned relative to the target widget.
enum ContentAlign {
  /// Position content above the target widget.
  top,

  /// Position content below the target widget.
  bottom,

  /// Position content to the left of the target widget.
  left,

  /// Position content to the right of the target widget.
  right,

  /// Use custom positioning with [CustomTargetContentPosition].
  custom
}

/// Builder function for creating dynamic tutorial content.
///
/// Provides access to [BuildContext] and [TutorialCoachMarkController]
/// for creating interactive or context-aware content.
typedef TargetContentBuilder = Widget Function(
  BuildContext context,
  TutorialCoachMarkController controller,
);

/// Represents content to be displayed around a focused target widget.
///
/// Each [TargetContent] defines what should be shown and where it should be
/// positioned relative to the focused widget. You can use either a static
/// [child] widget or a dynamic [builder] function.
///
/// Example with static content:
/// ```dart
/// TargetContent(
///   align: ContentAlign.bottom,
///   padding: EdgeInsets.all(20.0),
///   child: Column(
///     children: [
///       Text("Welcome!", style: TextStyle(fontSize: 20)),
///       Text("This is your dashboard."),
///     ],
///   ),
/// )
/// ```
///
/// Example with builder:
/// ```dart
/// TargetContent(
///   align: ContentAlign.top,
///   builder: (context, controller) {
///     return ElevatedButton(
///       onPressed: () => controller.next(),
///       child: Text("Next Step"),
///     );
///   },
/// )
/// ```
class TargetContent {
  TargetContent({
    this.align = ContentAlign.bottom,
    this.padding = const EdgeInsets.all(20.0),
    this.child,
    this.customPosition,
    this.builder,
  }) : assert(!(align == ContentAlign.custom && customPosition == null));

  /// Where to position this content relative to the target widget.
  /// When using [ContentAlign.custom], [customPosition] must be provided.
  final ContentAlign align;

  /// Padding around the content widget.
  final EdgeInsets padding;

  /// Custom positioning when [align] is set to [ContentAlign.custom].
  /// Must be provided when using custom alignment.
  final CustomTargetContentPosition? customPosition;

  /// Static widget to display as content.
  /// Either [child] or [builder] must be provided, but not both.
  final Widget? child;

  /// Dynamic builder function for creating content.
  /// Provides access to context and tutorial controller.
  /// Either [child] or [builder] must be provided, but not both.
  final TargetContentBuilder? builder;

  @override
  String toString() {
    return 'ContentTarget{align: $align, child: $child}';
  }
}
