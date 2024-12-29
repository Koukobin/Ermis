import 'package:flutter/material.dart';

class ErmisDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2) // Subtle doodle color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Circles
    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0; y < size.height; y += 50) {
        canvas.drawCircle(Offset(x, y), 15, paint);
      }
    }

    // Draw Wavy Lines
    for (double y = 20; y < size.height; y += 100) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(x + 25, y + 20, x + 50, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Redraw only if necessary
  }
}