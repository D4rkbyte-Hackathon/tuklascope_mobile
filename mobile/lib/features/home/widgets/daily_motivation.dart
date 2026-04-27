import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyMotivation extends StatelessWidget {
  final int streak;
  final int scans;

  const DailyMotivation({super.key, required this.streak, required this.scans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 40, color: theme.colorScheme.secondary),
              Text(
                "$streak Day Streak",
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
              )
            ],
          ),
          Container(
            height: 50, width: 1,
            color: theme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Siyensya Thursday 🧬", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.primary)),
                const SizedBox(height: 4),
                Text(
                  "Scan a plant to earn 2x XP today! ($scans/3 Scans)",
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1);
  }
}