import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/navigation/main_nav_scope.dart';
// 🚀 Add this import at the top to access the Scan Detail Screen
import '../../explore/presentation/screens/scan_detail_screen.dart';

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
                  const TextSpan(text: "You might like... \n", style: TextStyle(fontWeight: FontWeight.bold)),
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
// 2. MINI SKILL TREE CARD (DYNAMIC)
// =========================================================================
class MiniSkillTreeCard extends StatelessWidget {
  final Map<String, int> branchXp;

  const MiniSkillTreeCard({super.key, required this.branchXp});

  Widget _buildSkillNode(ThemeData theme, String label, int xp, Color color, IconData icon) {
    // 🚀 Exact same formula as skill_tree_screen.dart: Level = (xp ~/ 50) + 1
    final int level = (xp ~/ 50) + 1;
    // Calculate progress to next level (0.0 to 1.0)
    final double progress = (xp % 50) / 50.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 55, width: 55,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surface,
                color: color,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            // Tiny Level Badge
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                child: Text(
                  "Lv.$level",
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Skill Tree Mastery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkillNode(theme, "STEM", branchXp['STEM'] ?? 0, Colors.green[600]!, Icons.science),
              _buildSkillNode(theme, "HUMSS", branchXp['HUMSS'] ?? 0, Colors.orange[600]!, Icons.menu_book),
              _buildSkillNode(theme, "ABM", branchXp['ABM'] ?? 0, Colors.blue[600]!, Icons.attach_money),
              _buildSkillNode(theme, "TVL", branchXp['TVL'] ?? 0, Colors.red[500]!, Icons.electrical_services),
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
            Text("Active Quest", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            Text("Batang Siyentista", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
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
// 4. LEADERBOARD TEASER (GAMIFIED)
// =========================================================================
class LeaderboardTeaser extends StatelessWidget {
  final int? rank;
  final int totalUsers;

  const LeaderboardTeaser({super.key, required this.rank, required this.totalUsers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine Trophy Color based on rank
    Color trophyColor = theme.colorScheme.tertiary;
    if (rank == 1) trophyColor = Colors.amber;
    else if (rank == 2) trophyColor = Colors.grey[400]!;
    else if (rank == 3) trophyColor = Colors.brown[300]!;

    return GestureDetector(
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.tertiary.withOpacity(0.05)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.tertiary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.emoji_events_rounded, color: trophyColor, size: 28),
                Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.tertiary),
              ],
            ),
            const SizedBox(height: 8),
            Text("Global Rank", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  rank != null ? "#$rank" : "--", 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: theme.colorScheme.tertiary),
                ),
                Text(
                  " / $totalUsers", 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 500.ms).slideY(begin: 0.1);
  }
}
// =========================================================================
// 5. RECENT DISCOVERIES SECTION (HORIZONTAL LIST)
// =========================================================================
class RecentDiscoveriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentScans;

  const RecentDiscoveriesSection({super.key, required this.recentScans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Hide the section entirely if they haven't scanned anything yet
    if (recentScans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Discoveries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            GestureDetector(
              onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), // Jump to History/Explore
              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recentScans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final scan = recentScans[index];
              final objectName = scan['object_name'] as String? ?? 'Unknown';
              final imageUrl = scan['image_url'] as String?;
              final lens = scan['chosen_lens'] as String? ?? 'STEM';
              final scanId = scan['id'] as String? ?? '';

              return GestureDetector(
                onTap: () {
                  if (scanId.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScanDetailScreen(
                          scanId: scanId,
                          objectName: objectName,
                          imagUrl: imageUrl ?? '', // Note: using your 'imagUrl' spelling
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(
                                  color: theme.colorScheme.primary.withOpacity(0.1), 
                                  child: Icon(Icons.image_outlined, color: theme.colorScheme.primary)
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              objectName, 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lens.toUpperCase(), 
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary, letterSpacing: 0.5)
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fade(delay: 350.ms).slideX(begin: 0.1);
  }
}