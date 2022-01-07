import 'package:flutter/material.dart';

class ReplyArc extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color(0XFFD3D7EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    //draw arc
    canvas.drawArc(
      const Offset(0, 0) & const Size(24, 24),
      -3, //radians
      -2, //radians
      false,
      paint1,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
