import 'package:flutter/material.dart';

class AnimatedCirclePainter extends CustomPainter {
  final Color? color;

  AnimatedCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(size.center(Offset.zero), 40, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
