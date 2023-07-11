import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/circle_clipper.dart';

class LightPaint extends CustomPainter {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final Color colorShadow;
  final double opacityShadow;
  final BorderSide? borderSide;

  LightPaint(
    this.progress,
    this.positioned,
    this.sizeCircle, {
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.borderSide,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (positioned == Offset.zero) return;
    var maxSize = max(size.width, size.height);

    double radius = maxSize * (1 - progress) + sizeCircle;

    final circleHole = CircleClipper.circleHolePath(size, positioned, radius);

    final justCircleHole = Path()
      ..moveTo(positioned.dx - radius, positioned.dy)
      ..arcTo(
        Rect.fromCircle(center: positioned, radius: radius),
        pi,
        pi,
        false,
      )
      ..arcTo(
        Rect.fromCircle(center: positioned, radius: radius),
        0,
        pi,
        false,
      )
      ..close();

    canvas.drawPath(
      circleHole,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colorShadow.withOpacity(opacityShadow),
    );
    if (borderSide != null && borderSide?.style != BorderStyle.none) {
      canvas.drawPath(
          justCircleHole,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = borderSide!.color
            ..strokeWidth = borderSide!.width);
    }
  }

  @override
  bool shouldRepaint(LightPaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
