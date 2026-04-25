import 'dart:math' show pi, cos, sin;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../main_navigation.dart';
import 'compass_questions_screen.dart';

class CompassResultsScreen extends StatelessWidget {
  final Affinity topAffinity;
  final Map<Affinity, double> affinityScores;

  const CompassResultsScreen({
    super.key,
    required this.topAffinity,
    required this.affinityScores,
  });

  Map<String, dynamic> _getPersonaDetails(Affinity affinity) {
    switch (affinity) {
      case Affinity.stem:
        return {'title': 'The Innovator', 'icon': Icons.science_rounded};
      case Affinity.abm:
        return {'title': 'The Strategist', 'icon': Icons.trending_up_rounded};
      case Affinity.humss:
        return {'title': 'The Empath', 'icon': Icons.public_rounded};
      case Affinity.tvl:
        return {'title': 'The Builder', 'icon': Icons.handyman_rounded};
    }
  }

  String _getAffinityName(Affinity affinity) {
    switch (affinity) {
      case Affinity.stem:
        return 'STEM';
      case Affinity.abm:
        return 'ABM';
      case Affinity.humss:
        return 'HUMSS';
      case Affinity.tvl:
        return 'TVL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme
    final persona = _getPersonaDetails(topAffinity);
    final neonOrange = theme.colorScheme.secondary; // Themed Orange
    final primaryColor = theme.colorScheme.primary; // Themed Blue

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // --- HEADING ANIMATION ---
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    fontFamily: 'Roboto',
                  ),
                  children: [
                    TextSpan(
                      text: 'Your Journey\n',
                      style: TextStyle(color: primaryColor), // Themed
                    ),
                    TextSpan(
                      text: 'Begins',
                      style: TextStyle(color: neonOrange), // Themed
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms).slideY(
                    begin: -0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 24),

              // --- GLASSMORPHIC RESULT CARD ---
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.85), // Themed Adaptive Glass
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: neonOrange.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonOrange.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 1. PERSONA HEADER
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: neonOrange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              persona['icon'],
                              size: 48,
                              color: neonOrange,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            persona['title'],
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: primaryColor, // Themed
                            ),
                          ),
                          Text(
                            '${_getAffinityName(topAffinity)} Affinity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed
                              letterSpacing: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          Divider(thickness: 1.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)), // Themed
                          const Spacer(flex: 1),

                          // 2. 🚀 THE GAMIFIED DIAMOND STAT CHART 🚀
                          Expanded(
                            flex: 8,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.elasticOut,
                              builder: (context, animValue, child) {
                                return CustomPaint(
                                  size: const Size(double.infinity, double.infinity),
                                  painter: DiamondRadarPainter(
                                    scores: affinityScores,
                                    animationValue: animValue,
                                    neonColor: neonOrange,
                                    textColor: theme.colorScheme.onSurface, // Themed painter text
                                    gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.2), // Themed grid
                                    surfaceColor: theme.colorScheme.surface, // Themed dots
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(duration: 600.ms, delay: 200.ms).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 200.ms,
                    ),
              ),

              const SizedBox(height: 24),

              // --- FLOATING NEON BUTTON ---
              Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: neonOrange.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    )
                  ],
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.tertiary, neonOrange], // Themed
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        await Supabase.instance.client.from('compass_results').upsert({
                          'user_id': userId,
                          'stem_affinity': (affinityScores[Affinity.stem]! * 100).toInt(),
                          'abm_affinity': (affinityScores[Affinity.abm]! * 100).toInt(),
                          'humss_affinity': (affinityScores[Affinity.humss]! * 100).toInt(),
                          'tvl_affinity': (affinityScores[Affinity.tvl]! * 100).toInt(),
                        });
                      }
                    } catch (e) {
                      debugPrint('Failed to save compass results: $e');
                    }

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: theme.colorScheme.onSecondary, // Themed splash
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Start Your Discovery Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary, // Themed text
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                    delay: 400.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 🎮 CUSTOM GAMIFIED DIAMOND RADAR CHART PAINTER 🎮
// =========================================================================
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
    
    // Increased padding slightly to account for the new multiline text
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

  // 🚀 UPGRADED: Now accepts the Title AND the Percentage Value
  void _drawLabel(Canvas canvas, String title, String percentage, double x, double y, Alignment alignment) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: '$title\n',
          style: TextStyle(
            color: textColor, // Adaptive text color!
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        TextSpan(
          text: percentage,
          style: TextStyle(
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