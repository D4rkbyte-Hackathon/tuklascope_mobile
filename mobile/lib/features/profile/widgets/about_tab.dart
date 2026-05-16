import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatelessWidget {
  final ThemeData theme;

  const AboutTab({super.key, required this.theme});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Base delay for stagger choreography
    int delayStep = 100;
    int currentDelay = 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Hero / Mission Section
        _buildMissionCard()
            .animate()
            .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms)
            .slideY(begin: 0.1),

        const SizedBox(height: 24),

        // Features Section
        _buildSectionTitle('Core Features')
            .animate()
            .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms),
        const SizedBox(height: 12),
        ..._buildFeaturesList().map((feature) {
          return feature
              .animate()
              .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms)
              .slideX(begin: -0.05);
        }),

        const SizedBox(height: 24),

        // Tech Stack Section
        _buildSectionTitle('Tech Stack')
            .animate()
            .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms),
        const SizedBox(height: 12),
        _buildTechStackWrap()
            .animate()
            .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms)
            .scaleXY(begin: 0.9),

        const SizedBox(height: 32),

        // Developers Section
        _buildSectionTitle('The Developers')
            .animate()
            .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms),
        const SizedBox(height: 12),
        ..._buildDevelopersList(context).map((devCard) {
          return devCard
              .animate()
              .fade(duration: 400.ms, delay: (currentDelay += delayStep).ms)
              .slideY(begin: 0.1);
        }),

        const SizedBox(height: 40), // Bottom padding
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMissionCard() {
    return _GlassCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo Placeholder (replace with actual asset if you want)
          Icon(Icons.science, size: 64, color: theme.colorScheme.secondary)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 3.seconds, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Tuklascope',
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'An AI-powered educational mobile application designed to democratize learning and spark continuous, interdisciplinary curiosity among Filipino youth.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeaturesList() {
    final features = [
      {'icon': Icons.document_scanner, 'title': 'The Spark', 'desc': 'Interdisciplinary AR scanner for real-world object learning.'},
      {'icon': Icons.account_tree, 'title': 'Kaalaman Skill Tree', 'desc': 'Dynamic network graph tracking your holistic progress.'},
      {'icon': Icons.explore, 'title': 'Pathfinder AI', 'desc': 'Personalized K-12 academic and career guidance.'},
      {'icon': Icons.chat_bubble_outline, 'title': 'Conversational AI Tutor', 'desc': 'On-demand, culturally relevant AI mentoring.'},
      {'icon': Icons.emoji_events, 'title': 'Gamified Engagement', 'desc': 'Daily quests and leaderboards to build habits.'},
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _GlassCard(
          theme: theme,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                ),
                child: Icon(feature['icon'] as IconData, color: theme.colorScheme.secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['desc'] as String,
                      style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTechStackWrap() {
    final stack = ['Flutter', 'FastAPI', 'Gemini 2.5', 'Supabase', 'Neo4j', 'Qdrant', 'Python'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stack.map((tech) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          tech,
          style: GoogleFonts.inter(
              color: theme.colorScheme.primary, 
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      )).toList(),
    );
  }

  List<Widget> _buildDevelopersList(BuildContext context) {
    final devs = [
      {'name': 'John Michael A. Nave', 'role': 'Project Manager | Frontend', 'url': 'https://github.com/Goldenavs'},
      {'name': 'James Andrew S. Ologuin', 'role': 'Frontend Designer', 'url': 'https://github.com/OJamesAndrew'},
      {'name': 'John Peter D. Pestaño', 'role': 'Backend Developer', 'url': 'https://github.com/FloatingDust36'},
      {'name': 'Jordan A. Cabandon', 'role': 'Backend Developer', 'url': 'https://github.com/cabandonjordan'},
      {'name': 'John Zachary N. Gillana', 'role': 'Backend Developer', 'url': 'https://github.com/jzekken'},
    ];

    return devs.map((dev) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _launchUrl(context, dev['url']!),
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            highlightColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
            child: _GlassCard(
              theme: theme,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      dev['name']!.substring(0, 1),
                      style: GoogleFonts.orbitron(
                          color: theme.colorScheme.primary, 
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dev['name']!,
                          style: GoogleFonts.inter(
                              color: theme.colorScheme.onSurface, 
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dev['role']!,
                          style: GoogleFonts.inter(
                              color: theme.colorScheme.secondary, 
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, 
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3), 
                      size: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// A reusable Glassmorphic Card that adapts to your theme
class _GlassCard extends StatelessWidget {
  final ThemeData theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.3), // Semi-transparent surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}