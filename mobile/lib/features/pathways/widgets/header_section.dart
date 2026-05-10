import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/badges_screen.dart'; // 👈 NEW: Import the Badges Screen

class HeaderSection extends StatelessWidget {
  final int activePathways;
  final double averageProgress;
  final int totalPoints;

  const HeaderSection({
    super.key,
    required this.activePathways,
    required this.averageProgress,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 🚀 RESTORED: Original Two-Tone Title
          RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
              children: [
                TextSpan(
                  text: 'Learning ',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                TextSpan(
                  text: 'Pathways',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // 🚀 RESTORED: Original Centered Description
          Text(
            "Structured learning journeys that elevate the experience...",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8)
            ),
          ),
          const SizedBox(height: 30),

          // 🚀 NEW: 2x2 Layout to fit the Badge Button beautifully
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Active Pathways', '($activePathways)', Icons.explore, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Average Progress', '${averageProgress.toStringAsFixed(0)}%', Icons.trending_up, theme.colorScheme.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total Points', '($totalPoints)', Icons.stars, theme.colorScheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildBadgeButton(context)), // 👈 The new 4th Slot!
            ],
          ),
        ],
      ),
    );
  }

  // Generic Stat Card (Updated to accept your original colors!)
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color highlightColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 0)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlightColor, size: 22), // Swapped to highlightColor
          const SizedBox(height: 12),
          Text(
            value, 
            style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: highlightColor) // Swapped to highlightColor
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(), 
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))
          ),
        ],
      ),
    );
  }

  // The Highlighted Badge Call-To-Action Button
  Widget _buildBadgeButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // 🚀 Route to the new screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BadgesScreen()),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 0)
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.workspace_premium, color: theme.colorScheme.onPrimary, size: 22),
              const SizedBox(height: 12),
              Text('Badges', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
              const SizedBox(height: 4),
              Text('VIEW CASE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}