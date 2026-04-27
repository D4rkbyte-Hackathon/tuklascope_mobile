import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Make sure this path matches your project structure!
import '../../../core/navigation/main_nav_scope.dart';

// =========================================================================
// 1. QUICK RECOMMENDATION CARD
// =========================================================================
class QuickRecommendationCard extends StatelessWidget {
  const QuickRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: theme.colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                children: [
                  const TextSpan(
                    text: "You might like... \n", 
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Try scanning electronics 💻 (You're strong in TVL)",
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms);
  }
}

// =========================================================================
// 2. MINI SKILL TREE CARD
// =========================================================================
class MiniSkillTreeCard extends StatelessWidget {
  const MiniSkillTreeCard({super.key});

  // Helper inside the widget to draw the circular rings
  Widget _buildSkillPill(ThemeData theme, String label, double progress, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surface,
                color: color,
                strokeWidth: 6,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      // Routes to the Pathfinder / Skill Tree Tab (Index 3)
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skill Tree Preview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkillPill(theme, "STEM", 0.8, Colors.blue),
              _buildSkillPill(theme, "HUMSS", 0.4, Colors.purple),
              _buildSkillPill(theme, "ABM", 0.6, Colors.green),
              _buildSkillPill(theme, "TVL", 0.9, theme.colorScheme.secondary),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 300.ms);
  }
}

// =========================================================================
// 3. QUEST BOARD PREVIEW
// =========================================================================
class QuestBoardPreview extends StatelessWidget {
  const QuestBoardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      // Routes to the Pathways Tab (Index 2)
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(2), 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.map_rounded, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              "Active Quest", 
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            Text(
              "Batang Siyentista", 
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.3,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 400.ms).slideY(begin: 0.1);
  }
}

// =========================================================================
// 4. LEADERBOARD TEASER
// =========================================================================
class LeaderboardTeaser extends StatelessWidget {
  const LeaderboardTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      // Routes to the Explore / Leaderboard Tab (Index 4)
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.leaderboard_rounded, color: theme.colorScheme.tertiary),
            const SizedBox(height: 8),
            Text(
              "Your Rank", 
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            Text(
              "Top 10", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.tertiary),
            ),
            Text(
              "in your school", 
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 500.ms).slideY(begin: 0.1);
  }
}