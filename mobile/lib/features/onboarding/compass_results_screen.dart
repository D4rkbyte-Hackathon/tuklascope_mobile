import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../../main_navigation.dart';
import 'models/compass_data.dart';
import 'widgets/diamond_radar_painter.dart';

class CompassResultsScreen extends StatefulWidget {
  final Affinity topAffinity;
  final Map<Affinity, double> affinityScores;

  const CompassResultsScreen({
    super.key,
    required this.topAffinity,
    required this.affinityScores,
  });

  @override
  State<CompassResultsScreen> createState() => _CompassResultsScreenState();
}

class _CompassResultsScreenState extends State<CompassResultsScreen> {
  // 🚀 STATE: Tracks if the card is currently showing the back or front
  bool _isFlipped = false;

  List<Affinity> _getTopAffinities() {
    final double maxScore = widget.affinityScores.values.reduce(max);
    return widget.affinityScores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();
  }

  Map<String, dynamic> _getPersonaDetails(List<Affinity> topAffinities) {
    if (topAffinities.length > 1) {
      return {
        'title': 'The Polymath', 
        'icon': Icons.all_inclusive_rounded,
        'subtitle': 'Hybrid Affinity'
      };
    }

    switch (topAffinities.first) {
      case Affinity.stem:
        return {'title': 'The Innovator', 'icon': Icons.science_rounded, 'subtitle': 'STEM Affinity'};
      case Affinity.abm:
        return {'title': 'The Strategist', 'icon': Icons.trending_up_rounded, 'subtitle': 'ABM Affinity'};
      case Affinity.humss:
        return {'title': 'The Empath', 'icon': Icons.public_rounded, 'subtitle': 'HUMSS Affinity'};
      case Affinity.tvl:
        return {'title': 'The Builder', 'icon': Icons.handyman_rounded, 'subtitle': 'TVL Affinity'};
    }
  }

  // 🚀 ADDED: Flavor text engine for the back of the card
  String _getFlavorText(List<Affinity> topAffinities) {
    if (topAffinities.length > 1) {
      return "You are a rare blend of disciplines! Your diverse skill set allows you to bridge gaps between different fields, making you adaptable, versatile, and highly innovative. The world needs people who can think across boundaries just like you.";
    }
    switch (topAffinities.first) {
      case Affinity.stem:
        return "Your mind is wired for discovery and logic. You look at the world and see systems, patterns, and possibilities. Whether it's coding the next big app or researching new breakthroughs, your analytical nature makes you a natural problem-solver.";
      case Affinity.abm:
        return "You are a natural leader and a strategic thinker. You understand how value is created, managed, and multiplied. Your ability to organize resources and people means you're destined to build businesses or drive economies forward.";
      case Affinity.humss:
        return "You have a deep understanding of human nature and society. Your empathy and communication skills are your superpowers. You are drawn to fields where you can inspire others, advocate for change, and connect with people on a profound level.";
      case Affinity.tvl:
        return "You are a hands-on creator. While others theorize, you build. You have a practical, technical mindset that turns blueprints into reality. Your mastery of tools and techniques ensures that you leave a tangible, lasting impact on the world.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topAffinities = _getTopAffinities();
    final persona = _getPersonaDetails(topAffinities);
    final flavorText = _getFlavorText(topAffinities);
    
    final neonOrange = theme.colorScheme.secondary; 
    final primaryColor = theme.colorScheme.primary; 

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
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

                      // 🚀 THE INTERACTIVE FLIP CARD
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFlipped = !_isFlipped;
                          });
                        },
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: _isFlipped ? 1 : 0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack, // Gives the flip a nice bouncy finish
                          builder: (context, double value, child) {
                            // Check if we are past the 90 degree mark
                            final isBack = value >= 0.5;
                            // Calculate rotation
                            final rotation = value * pi;

                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // Adds 3D perspective depth
                                ..rotateY(rotation),
                              child: _buildGlassCard(
                                theme: theme,
                                neonOrange: neonOrange,
                                // If we are on the back, we MUST mirror the content by 180 degrees 
                                // so the text isn't displayed backwards!
                                child: isBack
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(pi),
                                        child: _buildBackContent(theme, persona, flavorText, neonOrange, primaryColor),
                                      )
                                    : _buildFrontContent(theme, persona, neonOrange, primaryColor),
                              ),
                            );
                          },
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.1)).animate().fade(duration: 600.ms, delay: 200.ms).slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                            delay: 200.ms,
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
                                  'stem_affinity': (widget.affinityScores[Affinity.stem]! * 100).toInt(),
                                  'abm_affinity': (widget.affinityScores[Affinity.abm]! * 100).toInt(),
                                  'humss_affinity': (widget.affinityScores[Affinity.humss]! * 100).toInt(),
                                  'tvl_affinity': (widget.affinityScores[Affinity.tvl]! * 100).toInt(),
                                }, onConflict: 'user_id'); 
                              }
                            } catch (e) {
                              debugPrint('Failed to save compass results: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Database Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                              return; 
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
                            style: GoogleFonts.montserrat( 
                              fontSize: 16,
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
          },
        ),
      ),
    );
  }

  // 🚀 REUSABLE GLASS CARD WRAPPER
  Widget _buildGlassCard({required Widget child, required ThemeData theme, required Color neonOrange}) {
    return Container(
      width: double.infinity,
      // Forces the card to stay tall, so it doesn't shrink awkwardly when showing the text
      constraints: const BoxConstraints(minHeight: 480),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: neonOrange.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(color: neonOrange.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // 🚀 FRONT OF CARD (Radar Chart)
  Widget _buildFrontContent(ThemeData theme, Map<String, dynamic> persona, Color neonOrange, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .scaleXY(end: 1.1, duration: 1500.ms, curve: Curves.easeInOut),

        const SizedBox(height: 16),

        Text(
          persona['title'],
          style: GoogleFonts.montserrat( 
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: primaryColor, 
          ),
        ),
        Text(
          persona['subtitle'],
          style: GoogleFonts.inter( 
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
            letterSpacing: 1.5,
          ),
        ),
        
        const SizedBox(height: 20),
        Divider(thickness: 1.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)), 
        const SizedBox(height: 24), 

        SizedBox(
          height: 260, 
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: neonOrange.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ]
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .fade(begin: 0.5, end: 1.0, duration: 2.seconds),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.elasticOut,
                builder: (context, animValue, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: DiamondRadarPainter(
                      scores: widget.affinityScores,
                      animationValue: animValue,
                      neonColor: neonOrange,
                      textColor: theme.colorScheme.onSurface,
                      gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.2), 
                      surfaceColor: theme.colorScheme.surface, 
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Tap affordance
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Tap to analyze', style: GoogleFonts.inter(fontSize: 12, color: neonOrange.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.touch_app_rounded, size: 16, color: neonOrange.withValues(alpha: 0.8)),
          ],
        ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.4, end: 1.0, duration: 1.seconds),
      ],
    );
  }

  // 🚀 BACK OF CARD (Flavor Text)
  Widget _buildBackContent(ThemeData theme, Map<String, dynamic> persona, String flavorText, Color neonOrange, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(persona['icon'], size: 40, color: neonOrange),
        const SizedBox(height: 16),
        Text(
          'Your Path Explained',
          style: GoogleFonts.montserrat( 
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: primaryColor, 
          ),
        ),
        const SizedBox(height: 24),
        Text(
          flavorText,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter( 
            fontSize: 16,
            height: 1.6,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8), 
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cached_rounded, size: 16, color: neonOrange.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text('Tap to return', style: GoogleFonts.inter(fontSize: 12, color: neonOrange.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}