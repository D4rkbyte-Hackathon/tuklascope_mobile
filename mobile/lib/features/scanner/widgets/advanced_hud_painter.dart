import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedHudPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  AdvancedHudPainter(this.primary, this.secondary);

  @override
  void paint(Canvas canvas, Size size) {
    const double boxWidth = 280;
    const double boxHeight = 350;
    final double left = (size.width - boxWidth) / 2;
    final double top = (size.height - boxHeight) / 2;
    final double right = left + boxWidth;
    final double bottom = top + boxHeight;

    final outlinePaint = Paint()
      ..color = primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bracketPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;

    final accentPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    // 1. Draw subtle grid behind everything
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        Paint()..color = Colors.white.withValues(alpha: 0.03),
      );
    }
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        Paint()..color = Colors.white.withValues(alpha: 0.03),
      );
    }

    // 2. Draw thin border around the camera box
    final RRect scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxWidth, boxHeight),
      const Radius.circular(16),
    );
    canvas.drawRRect(scanRect, outlinePaint);

    // 3. Draw Heavy Sci-Fi Corner Brackets
    const double length = 40.0;
    const double offset = 8.0;

    // Top Left
    canvas.drawLine(Offset(left - offset, top + length), Offset(left - offset, top - offset), bracketPaint);
    canvas.drawLine(Offset(left - offset, top - offset), Offset(left + length, top - offset), bracketPaint);

    // Top Right
    canvas.drawLine(Offset(right + offset, top + length), Offset(right + offset, top - offset), bracketPaint);
    canvas.drawLine(Offset(right + offset, top - offset), Offset(right - length, top - offset), bracketPaint);

    // Bottom Left
    canvas.drawLine(Offset(left - offset, bottom - length), Offset(left - offset, bottom + offset), bracketPaint);
    canvas.drawLine(Offset(left - offset, bottom + offset), Offset(left + length, bottom + offset), bracketPaint);

    // Bottom Right
    canvas.drawLine(Offset(right + offset, bottom - length), Offset(right + offset, bottom + offset), bracketPaint);
    canvas.drawLine(Offset(right + offset, bottom + offset), Offset(right - length, bottom + offset), bracketPaint);

    // 4. Draw Telemetry Accents
    canvas.drawCircle(Offset(left - offset, top - offset), 4, accentPaint);
    canvas.drawCircle(Offset(right + offset, bottom + offset), 4, accentPaint);

    // 5. Draw Crosshair ticks inside the box
    final crosshairPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = left + (boxWidth / 2);
    final centerY = top + (boxHeight / 2);

    canvas.drawLine(Offset(centerX, top + 20), Offset(centerX, top + 40), crosshairPaint); 
    canvas.drawLine(Offset(centerX, bottom - 20), Offset(centerX, bottom - 40), crosshairPaint); 
    canvas.drawLine(Offset(left + 20, centerY), Offset(left + 40, centerY), crosshairPaint); 
    canvas.drawLine(Offset(right - 20, centerY), Offset(right - 40, centerY), crosshairPaint); 

    // 6. Draw Text Data
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCAN STATUS: READY\nPOSITION: OPTIMAL',
        style: GoogleFonts.orbitron(
          color: primary.withValues(alpha: 0.7),
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(left - offset, top - 35)); 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}