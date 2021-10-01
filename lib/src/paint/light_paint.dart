import 'dart:math';

import 'package:flutter/material.dart';

class LightPaint extends CustomPainter {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final Color colorShadow;
  final double opacityShadow;
  Path? circleHole;

  LightPaint(
    this.progress,
    this.positioned,
    this.sizeCircle, {
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (positioned == Offset.zero) return;
    var maxSize = max(size.width, size.height);

    double radius = maxSize * (1 - progress) + sizeCircle;

    // There is some weirdness here.  On mobile, using arcTo with `sweepAngle: 2 * pi`
    // gives the equivalent of `sweepAngle: 0`.  I couldn't find any documentation
    // of the expected behavior here, so instead I just call arcTo twice (two
    // semi-circles) to outline the full hole.
    circleHole = Path()
      ..moveTo(0, 0)
      ..lineTo(0, positioned.dy)
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
      ..lineTo(0, positioned.dy)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      circleHole!,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colorShadow.withOpacity(opacityShadow),
    );
  }

  @override
  bool hitTest(Offset position) => circleHole!.contains(position);

  @override
  bool shouldRepaint(LightPaint oldDelegate) => true;
}
