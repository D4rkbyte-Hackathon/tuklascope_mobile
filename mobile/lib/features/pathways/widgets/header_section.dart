import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  // Best Practice: Pass these in as parameters instead of reading globals
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
          Text(
            "Structured learning journeys that elevate the experience...",
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("($activePathways)", "Active Pathways", Colors.green, theme),
              _buildStat("$averageProgress%", "Average Progress", theme.colorScheme.secondary, theme),
            ],
          ),
          const SizedBox(height: 20),
          _buildStat("($totalPoints)", "Total Points Earned", theme.colorScheme.primary, theme),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color numcolor, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: numcolor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}