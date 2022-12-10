import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool reverse;
  TrianglePainter({this.color = Colors.black, this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(
        reverse
            ? getReversePath(size.width, size.height)
            : getForwardPath(size.width, size.height),
        paint);
  }

  Path getReversePath(x, y) {
    final path = Path();
    path.moveTo(x, y);
    path.lineTo(0, y / 2);
    path.lineTo(x, 0);
    path.lineTo(x, y);
    return path;
  }

  Path getForwardPath(x, y) {
    final path = Path();
    path.moveTo(0, y);
    path.lineTo(x, y / 2);
    path.lineTo(0, 0);
    path.lineTo(0, y);
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
