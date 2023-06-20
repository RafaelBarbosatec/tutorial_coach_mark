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

    return circleHolePath(size, positioned, radius);
  }

  // There is some weirdness here.  On mobile, using arcTo with `sweepAngle: 2 * pi`
  // gives the equivalent of `sweepAngle: 0`.  I couldn't find any documentation
  // of the expected behavior here, so instead I just call arcTo twice (two
  // semi-circles) to outline the full hole.
  static Path circleHolePath(
    Size size,
    Offset positioned,
    double radius,
  ) {
    return Path()
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
  }

  @override
  bool shouldReclip(covariant CircleClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
