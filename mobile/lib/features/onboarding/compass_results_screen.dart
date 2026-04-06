import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../main_navigation.dart';
import 'compass_questions_screen.dart'; // To access the Affinity enum

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
        return {'title': 'The Innovator', 'icon': Icons.science};
      case Affinity.abm:
        return {'title': 'The Strategist', 'icon': Icons.trending_up};
      case Affinity.humss:
        return {'title': 'The Empath', 'icon': Icons.public};
      case Affinity.tvl:
        return {'title': 'The Builder', 'icon': Icons.build};
    }
  }

  String _getAffinityName(Affinity affinity) {
    switch (affinity) {
      case Affinity.stem: return 'STEM';
      case Affinity.abm: return 'ABM';
      case Affinity.humss: return 'HUMSS';
      case Affinity.tvl: return 'TVL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final persona = _getPersonaDetails(topAffinity);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        // 1. ADDED: LayoutBuilder & ScrollView to prevent overflow!
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Nice bouncy scroll effect
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // --- HEADING ANIMATION ---
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              fontFamily: 'Roboto', 
                            ),
                            children: [
                              TextSpan(
                                text: 'Your Journey\n',
                                style: TextStyle(color: Color(0xFF0B3C6A)), 
                              ),
                              TextSpan(
                                text: 'Begins',
                                style: TextStyle(color: Color(0xFFFF6B2C)), 
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                        const SizedBox(height: 40),

                        // --- RESULT CARD ANIMATION ---
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B2C).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    persona['icon'], 
                                    size: 64,
                                    color: const Color(0xFFFF6B2C), 
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Text(
                                  persona['title'], 
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3C6A), 
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_getAffinityName(topAffinity)} Affinity', 
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                const Divider(thickness: 1.5),
                                const SizedBox(height: 24),

                                // --- REAL DYNAMIC STATS ---
                                _buildStatRow('STEM (Science & Tech)', affinityScores[Affinity.stem]!),
                                const SizedBox(height: 16),
                                _buildStatRow('ABM (Business & Mgt)', affinityScores[Affinity.abm]!),
                                const SizedBox(height: 16),
                                _buildStatRow('HUMSS (Humanities)', affinityScores[Affinity.humss]!),
                                const SizedBox(height: 16),
                                _buildStatRow('TVL (Tech & Voc)', affinityScores[Affinity.tvl]!),
                              ],
                            ),
                          )
                          .animate()
                          .fade(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 200.ms),
                        ),
                        
                        const SizedBox(height: 30),

                        // --- BUTTON ANIMATION ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainNavigation()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B2C), 
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFFF6B2C).withOpacity(0.5),
                            ),
                            child: const Text(
                              'Start Your Discovery Journey',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 400.ms),

                        const SizedBox(height: 40), 
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- HELPER: ANIMATED STAT PROGRESS BARS ---
  Widget _buildStatRow(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C6A),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B2C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 6, 
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2C)),
              );
            },
          ),
        ),
      ],
    );
  }
}