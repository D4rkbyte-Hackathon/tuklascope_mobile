import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/navigation/main_nav_scope.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String heroTitle;
  final int xp;
  final String? avatarUrl;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.heroTitle,
    required this.xp,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // 2. Clickable Profile Icon -> Jumps to Tab 3 (Pathfinder)
        GestureDetector(
          onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surface,
              // 1. Display fetched image if available, otherwise show Icon
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null 
                  ? Icon(Icons.person, size: 32, color: theme.colorScheme.primary) 
                  : null,
            ),
          ),
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