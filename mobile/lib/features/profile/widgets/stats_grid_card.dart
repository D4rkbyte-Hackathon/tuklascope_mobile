import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_models.dart';

class StatsGridCard extends StatelessWidget {
  final ThemeData theme;
  final ProfileStats stats;
  
  const StatsGridCard({super.key, required this.theme, required this.stats});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCell(
                  value: '${stats.progressToNextLevel}%',
                  label: 'To Level ${stats.currentLevel + 1}',
                  valueColor: theme.colorScheme.secondary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: StatCell(
                  value: '${stats.totalXp}',
                  label: 'Total EXP',
                  valueColor: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCell(
                  value: '${stats.conceptsMastered}',
                  label: 'Concepts Mastered',
                  valueColor: const Color(0xFF4CAF50),
                  theme: theme,
                ),
              ),
              Expanded(
                child: StatCell(
                  value: '${stats.currentLevel}',
                  label: 'Average Level',
                  valueColor: theme.colorScheme.tertiary,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final ThemeData theme;
  
  const StatCell({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.theme,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}