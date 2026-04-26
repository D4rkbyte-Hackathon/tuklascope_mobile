import 'package:flutter/material.dart';

class DiscovererRowCard extends StatelessWidget {
  const DiscovererRowCard({
    super.key,
    required this.name,
    required this.xpLabel,
    required this.orangeBorder,
    required this.trophyColor,
    required this.rank,
    required this.onTap,
    this.avatarUrl, // 🚀 ADDED: Avatar parameter
  });

  final String name;
  final String xpLabel;
  final Color orangeBorder;
  final Color trophyColor;
  final int rank;
  final VoidCallback onTap;
  final String? avatarUrl; // 🚀 ADDED: Avatar parameter

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: orangeBorder, width: 1.4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 🚀 UPDATED: Avatar with an overlapping rank badge
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: trophyColor.withValues(alpha: 0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null 
                            ? Icon(Icons.person, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)) 
                            : null,
                      ),
                    ),
                    // Floating Rank Badge
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: trophyColor, width: 1.5),
                        ),
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: trophyColor,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}