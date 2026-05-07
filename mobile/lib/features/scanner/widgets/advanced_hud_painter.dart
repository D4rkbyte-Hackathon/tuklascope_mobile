import 'package:flutter/material.dart';

class AdvancedHudPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final double boxWidth;
  final double boxHeight;

  AdvancedHudPainter({
    required this.primary, 
    required this.secondary,
    required this.boxWidth,
    required this.boxHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - boxWidth) / 2;
    final double top = (size.height - boxHeight) / 2;
    final double right = left + boxWidth;
    final double bottom = top + boxHeight;

    final outlinePaint = Paint()
      ..color = primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final primaryBracket = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;
      
    final secondaryBracket = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;

    // 1. Draw subtle grid behind everything
    final gridPaint = Paint()..color = primary.withValues(alpha: 0.05);
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }

    // 2. Draw thin border
    final RRect scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxWidth, boxHeight),
      const Radius.circular(16),
    );
    canvas.drawRRect(scanRect, outlinePaint);

    // 3. Draw Heavy Sci-Fi Brackets 
    const double length = 40.0;
    const double offset = 8.0;

    // Top Left (Primary)
    canvas.drawLine(Offset(left - offset, top + length), Offset(left - offset, top - offset), primaryBracket);
    canvas.drawLine(Offset(left - offset, top - offset), Offset(left + length, top - offset), primaryBracket);

    // Bottom Right (Primary)
    canvas.drawLine(Offset(right + offset, bottom - length), Offset(right + offset, bottom + offset), primaryBracket);
    canvas.drawLine(Offset(right + offset, bottom + offset), Offset(right - length, bottom + offset), primaryBracket);

    // Top Right (Secondary)
    canvas.drawLine(Offset(right + offset, top + length), Offset(right + offset, top - offset), secondaryBracket);
    canvas.drawLine(Offset(right + offset, top - offset), Offset(right - length, top - offset), secondaryBracket);

    // Bottom Left (Secondary)
    canvas.drawLine(Offset(left - offset, bottom - length), Offset(left - offset, bottom + offset), secondaryBracket);
    canvas.drawLine(Offset(left - offset, bottom + offset), Offset(left + length, bottom + offset), secondaryBracket);

    // 4. Crosshairs (Secondary)
    final crosshairPaint = Paint()
      ..color = secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = left + (boxWidth / 2);
    final centerY = top + (boxHeight / 2);

    canvas.drawLine(Offset(centerX, top + 20), Offset(centerX, top + 40), crosshairPaint); 
    canvas.drawLine(Offset(centerX, bottom - 20), Offset(centerX, bottom - 40), crosshairPaint); 
    canvas.drawLine(Offset(left + 20, centerY), Offset(left + 40, centerY), crosshairPaint); 
    canvas.drawLine(Offset(right - 20, centerY), Offset(right - 40, centerY), crosshairPaint); 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}