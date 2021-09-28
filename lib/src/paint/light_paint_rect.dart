import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';

class LightPaintRect extends CustomPainter {
  final double progress;
  final TargetPosition target;
  final Color colorShadow;
  final double opacityShadow;
  final double offset;
  final double radius;
  Path? path;

  LightPaintRect({
    required this.progress,
    required this.target,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.offset = 10,
    this.radius = 10,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  static Path _drawRectHole(
    Size canvasSize,
    double x,
    double y,
    double w,
    double h,
  ) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, y)
      ..lineTo(x + w, y)
      ..lineTo(x + w, y + h)
      ..lineTo(x, y + h)
      ..lineTo(x, y)
      ..lineTo(0, y)
      ..lineTo(0, canvasSize.height)
      ..lineTo(canvasSize.width, canvasSize.height)
      ..lineTo(canvasSize.width, 0)
      ..close();
  }

  static Path _drawRRectHole(
    Size canvasSize,
    double x,
    double y,
    double w,
    double h,
    double radius,
  ) {
    double diameter = radius * 2;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, y + radius)
      ..arcTo(
        Rect.fromLTWH(x, y, diameter, diameter),
        pi,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y, diameter, diameter),
        3 * pi / 2,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y + h - diameter, diameter, diameter),
        0,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x, y + h - diameter, diameter, diameter),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(x, y + radius)
      ..lineTo(0, y + radius)
      ..lineTo(0, canvasSize.height)
      ..lineTo(canvasSize.width, canvasSize.height)
      ..lineTo(canvasSize.width, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (target.offset == Offset.zero) return;

    var maxSize = max(size.width, size.height) +
        max(target.size.width, target.size.height) +
        target.getBiggerSpaceBorder(size);

    double x = -maxSize / 2 * (1 - progress) + target.offset.dx - offset / 2;

    double y = -maxSize / 2 * (1 - progress) + target.offset.dy - offset / 2;

    double w = maxSize * (1 - progress) + target.size.width + offset;

    double h = maxSize * (1 - progress) + target.size.height + offset;

    path = radius > 0
        ? _drawRRectHole(size, x, y, w, h, radius)
        : _drawRectHole(size, x, y, w, h);

    canvas.drawPath(
      path!,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colorShadow.withOpacity(opacityShadow),
    );
  }

  @override
  bool hitTest(Offset position) {
    return path?.contains(position) ?? false;
  }

  @override
  bool shouldRepaint(LightPaintRect oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
