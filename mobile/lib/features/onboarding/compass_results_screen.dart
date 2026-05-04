import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS

import '../../core/widgets/gradient_scaffold.dart';
import '../../main_navigation.dart';
import 'models/compass_data.dart';
import 'widgets/diamond_radar_painter.dart';

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
    final theme = Theme.of(context);
    final persona = _getPersonaDetails(topAffinity);
    final neonOrange = theme.colorScheme.secondary; 
    final primaryColor = theme.colorScheme.primary; 

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

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT, REMOVED ROBOTO
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Your Journey\n',
                      style: TextStyle(color: primaryColor), 
                    ),
                    TextSpan(
                      text: 'Begins',
                      style: TextStyle(color: neonOrange), 
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

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.85), 
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
                            style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: primaryColor, 
                            ),
                          ),
                          Text(
                            '${_getAffinityName(topAffinity)} Affinity',
                            style: GoogleFonts.inter( // 🚀 SWAPPED TO INTER
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                              letterSpacing: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          Divider(thickness: 1.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)), 
                          const Spacer(flex: 1),

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
                                    textColor: theme.colorScheme.onSurface,
                                    gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.2), 
                                    surfaceColor: theme.colorScheme.surface, 
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
                    colors: [theme.colorScheme.tertiary, neonOrange], 
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
                    foregroundColor: theme.colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Start Your Discovery Journey',
                    style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary, 
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