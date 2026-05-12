import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pathway_models.dart';

class StatsBlock extends StatelessWidget {
  final Pathway pathway;

  const StatsBlock({super.key, required this.pathway});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.star, "${pathway.totalPoints}", "Points", theme),
        _buildStatItem(Icons.trending_up, pathway.difficulty, "Level", theme),
        _buildStatItem(
          Icons.check_circle,
          "${pathway.tasks.length}",
          "Tasks",
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
