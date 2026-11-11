import 'package:flutter/material.dart';

class LegoTheme {
  static const Color red = Color(0xFFD11013);
  static const Color yellow = Color(0xFFFFD500);
  static const Color blue = Color(0xFF0055BF);
  static const Color green = Color(0xFF00852B);
  static const Color black = Color(0xFF1B1B1B);
  static const Color plateBg = Color(0xFFF4F1EA);
  static const Color studColor = Color(0xFFE5DFC9);
  static const Color cardBg = Colors.white;
}

/// Painter to draw subtle LEGO plate studs grid on any background
class LegoStudPainter extends CustomPainter {
  final Color studColor;
  final double spacing;
  final double radius;

  const LegoStudPainter({
    this.studColor = LegoTheme.studColor,
    this.spacing = 32.0,
    this.radius = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = studColor
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
