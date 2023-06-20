import 'dart:math';

import 'package:flutter/rendering.dart';

class CircleClipper extends CustomClipper<Path> {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final BorderSide? borderSide;

  CircleClipper(
    this.progress,
    this.positioned,
    this.sizeCircle,
    this.borderSide,
  );

  @override
  Path getClip(Size size) {
    if (positioned == Offset.zero) return Path();
    var maxSize = max(size.width, size.height);

    double radius = maxSize * (1 - progress) + sizeCircle;
    final circleHole = Path()
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
    return circleHole;
  }

  @override
  bool shouldReclip(covariant CircleClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
