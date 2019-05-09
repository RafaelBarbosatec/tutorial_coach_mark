import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LightPaint extends CustomPainter {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final Color colorShadow;

  Paint _paintFocus;

  LightPaint(this.progress, this.positioned, this.sizeCircle,
      {this.colorShadow = Colors.black}) {
    _paintFocus = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(colorShadow.withOpacity(0.8), BlendMode.dstATop);

    var maxSise = size.width > size.height ? size.width : size.height;

    double radius = maxSise * (1 - progress) + sizeCircle;

    canvas.drawCircle(positioned, radius, _paintFocus);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LightPaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
