import 'dart:math';
import 'dart:ui';

/// Defines a custom position and size for a tutorial target when not using [GlobalKey].
///
/// Use this class when you want to focus on a specific area of the screen
/// without relying on a widget's [GlobalKey]. This is useful for highlighting
/// areas that don't correspond to a specific widget.
///
/// Example:
/// ```dart
/// TargetPosition(
///   Size(100, 50),        // width: 100, height: 50
///   Offset(150, 200),     // x: 150, y: 200
/// )
/// ```
class TargetPosition {
  /// The size (width and height) of the target area.
  final Size size;

  /// The position (x, y coordinates) of the target area's top-left corner.
  final Offset offset;

  TargetPosition(this.size, this.offset);

  /// Gets the center point of the target area.
  ///
  /// Calculates the center by adding half the width and height to the offset.
  Offset get center => Offset(
        offset.dx + size.width / 2,
        offset.dy + size.height / 2,
      );

  /// Calculates the maximum distance from the center to any screen border.
  ///
  /// This is used internally for animation calculations to ensure the focus
  /// animation covers the entire screen properly.
  ///
  /// [size] The size of the screen or container.
  double getBiggerSpaceBorder(Size size) {
    double maxDistanceX =
        center.dx > size.width / 2 ? center.dx : size.width - center.dx;
    double maxDistanceY =
        center.dy > size.height / 2 ? center.dy : size.height - center.dy;
    return max(maxDistanceX, maxDistanceY);
  }
}
