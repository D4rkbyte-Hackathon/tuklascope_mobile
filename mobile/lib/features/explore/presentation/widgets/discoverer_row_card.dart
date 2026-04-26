import 'package:flutter/material.dart';

class DiscovererRowCard extends StatelessWidget {
  const DiscovererRowCard({
    super.key,
    required this.name,
    required this.xpLabel,
    required this.orangeBorder,
    required this.trophyColor,
    required this.rank,
  });

  final String name;
  final String xpLabel;
  final Color orangeBorder;
  final Color trophyColor;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: orangeBorder, width: 1.4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20, 
              backgroundColor: trophyColor.withValues(alpha: 0.15),
              child: Text(
                '#$rank',
                style: TextStyle(fontWeight: FontWeight.bold, color: trophyColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    xpLabel,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            if (rank <= 3) 
              Icon(Icons.emoji_events, size: 30, color: trophyColor),
          ],
        ),
      ),
    );
  }
}