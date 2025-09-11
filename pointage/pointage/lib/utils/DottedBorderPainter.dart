import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final List<double> dashPattern;
  final double strokeWidth;

  DottedBorderPainter({
    required this.radius,
    required this.color,
    required this.dashPattern,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(radius),
          ),
        );

    final dashLength = dashPattern[0];
    final dashSpace = dashPattern[1];
    double distance = 0.0;

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
