import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS
import '../models/compass_data.dart';

class DiamondRadarPainter extends CustomPainter {
  final Map<Affinity, double> scores;
  final double animationValue;
  final Color neonColor;
  final Color textColor;
  final Color gridColor;
  final Color surfaceColor;

  DiamondRadarPainter({
    required this.scores,
    required this.animationValue,
    required this.neonColor,
    required this.textColor,
    required this.gridColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Increased padding slightly to account for the multiline text
    final double maxRadius = (size.shortestSide / 2) - 40; 

    // --- 1. DRAW BACKGROUND GRID (Spiderweb) ---
    final gridPaint = Paint()
      ..color = gridColor // Adaptive grid color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 0.25; i <= 1.0; i += 0.25) {
      final r = maxRadius * i;
      final path = Path()
        ..moveTo(centerX, centerY - r) 
        ..lineTo(centerX + r, centerY) 
        ..lineTo(centerX, centerY + r) 
        ..lineTo(centerX - r, centerY) 
        ..close();
      canvas.drawPath(path, gridPaint);
    }

    canvas.drawLine(Offset(centerX, centerY - maxRadius), Offset(centerX, centerY + maxRadius), gridPaint);
    canvas.drawLine(Offset(centerX - maxRadius, centerY), Offset(centerX + maxRadius, centerY), gridPaint);

    // --- 2. CALCULATE POLYGON POINTS ---
    double getScore(Affinity a) => (scores[a] ?? 0.0).clamp(0.1, 1.0) * animationValue;

    final Offset stemPoint = Offset(centerX, centerY - (maxRadius * getScore(Affinity.stem)));
    final Offset abmPoint = Offset(centerX + (maxRadius * getScore(Affinity.abm)), centerY);
    final Offset humssPoint = Offset(centerX, centerY + (maxRadius * getScore(Affinity.humss)));
    final Offset tvlPoint = Offset(centerX - (maxRadius * getScore(Affinity.tvl)), centerY);

    // --- 3. DRAW THE USER'S GAMIFIED STAT POLYGON ---
    final polygonPath = Path()
      ..moveTo(stemPoint.dx, stemPoint.dy)
      ..lineTo(abmPoint.dx, abmPoint.dy)
      ..lineTo(humssPoint.dx, humssPoint.dy)
      ..lineTo(tvlPoint.dx, tvlPoint.dy)
      ..close();

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          neonColor.withValues(alpha: 0.6),
          neonColor.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: maxRadius))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(polygonPath, fillPaint);

    final strokePaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(polygonPath, strokePaint);

    final dotPaint = Paint()
      ..color = surfaceColor // Adaptive dot color
      ..style = PaintingStyle.fill;
      
    final dotStrokePaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var point in [stemPoint, abmPoint, humssPoint, tvlPoint]) {
      canvas.drawCircle(point, 4.0, dotPaint);
      canvas.drawCircle(point, 4.0, dotStrokePaint);
    }

    // --- 4. CALCULATE ANIMATED PERCENTAGES ---
    final String stemPct = '${((scores[Affinity.stem] ?? 0) * animationValue * 100).toInt()}%';
    final String abmPct = '${((scores[Affinity.abm] ?? 0) * animationValue * 100).toInt()}%';
    final String humssPct = '${((scores[Affinity.humss] ?? 0) * animationValue * 100).toInt()}%';
    final String tvlPct = '${((scores[Affinity.tvl] ?? 0) * animationValue * 100).toInt()}%';

    // --- 5. DRAW TEXT LABELS ---
    _drawLabel(canvas, 'STEM', stemPct, centerX, centerY - maxRadius - 10, Alignment.bottomCenter);
    _drawLabel(canvas, 'ABM', abmPct, centerX + maxRadius + 15, centerY, Alignment.centerLeft);
    _drawLabel(canvas, 'HUMSS', humssPct, centerX, centerY + maxRadius + 10, Alignment.topCenter);
    _drawLabel(canvas, 'TVL', tvlPct, centerX - maxRadius - 15, centerY, Alignment.centerRight);
  }

  void _drawLabel(Canvas canvas, String title, String percentage, double x, double y, Alignment alignment) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: '$title\n',
          style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        TextSpan(
          text: percentage,
          style: GoogleFonts.orbitron( // 🚀 SWAPPED TO ORBITRON FOR GAMIFIED NUMBERS
            color: neonColor, 
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center, 
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    double dx = x;
    double dy = y;
    
    if (alignment == Alignment.bottomCenter) {
      dx -= textPainter.width / 2;
      dy -= textPainter.height;
    } else if (alignment == Alignment.topCenter) {
      dx -= textPainter.width / 2;
    } else if (alignment == Alignment.centerLeft) {
      dy -= textPainter.height / 2;
    } else if (alignment == Alignment.centerRight) {
      dx -= textPainter.width;
      dy -= textPainter.height / 2;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant DiamondRadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}