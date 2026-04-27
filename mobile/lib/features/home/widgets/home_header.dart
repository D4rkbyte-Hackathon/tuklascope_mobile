import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String heroTitle;
  final int xp;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.heroTitle,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Icon(Icons.person, size: 32, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, $userName",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                heroTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.stars_rounded, color: theme.colorScheme.tertiary, size: 20),
              const SizedBox(width: 6),
              Text(
                "$xp XP",
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary),
              ),
            ],
          ),
        ),
      ].animate(interval: 50.ms).fade().slideX(begin: -0.1),
    );
  }
}