import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/navigation/main_nav_scope.dart';
import '../../explore/presentation/screens/scan_detail_screen.dart';
import '../../pathways/models/pathway_models.dart';
import '../../pathways/providers/pathways_provider.dart';

// =========================================================================
// 1. QUICK RECOMMENDATION CARD (DYNAMIC)
// =========================================================================
class QuickRecommendationCard extends StatelessWidget {
  final Map<String, int> branchXp;

  const QuickRecommendationCard({super.key, required this.branchXp});

  String _getDynamicRecommendation(String highestBranch) {
    switch (highestBranch) {
      case 'STEM': return "Try scanning plants or gadgets 🔬 (You're strong in STEM)";
      case 'HUMSS': return "Try scanning books or art 📚 (You're strong in HUMSS)";
      case 'ABM': return "Try scanning products or storefronts 📈 (You're strong in ABM)";
      case 'TVL': return "Try scanning electronics or tools 💻 (You're strong in TVL)";
      default: return "Try scanning new objects around you! 🔍";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Find the branch with the highest XP
    String highestBranch = 'STEM';
    int maxXp = -1;
    branchXp.forEach((key, value) {
      if (value > maxXp) {
        maxXp = value;
        highestBranch = key;
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
        ]
      ),
      child: Row(
        children: [
          // Glowing Lightbulb
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.tertiary.withOpacity(0.2),
            ),
            child: Icon(Icons.lightbulb_rounded, color: theme.colorScheme.tertiary)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1.seconds),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW DIRECTIVE", 
                  style: GoogleFonts.orbitron(
                    color: theme.colorScheme.primary, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  _getDynamicRecommendation(highestBranch),
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.9), 
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms).slideX(begin: 0.05);
  }
}

// =========================================================================
// 2. MINI SKILL TREE CARD (DYNAMIC & GAMIFIED)
// =========================================================================
class MiniSkillTreeCard extends StatelessWidget {
  final Map<String, int> branchXp;

  const MiniSkillTreeCard({super.key, required this.branchXp});

  Widget _buildSkillNode(ThemeData theme, String label, int xp, Color color, IconData icon) {
    final int level = (xp ~/ 50) + 1;
    final double progress = (xp % 50) / 50.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer Glow
            Container(
              height: 55, width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)],
              ),
            ),
            // Progress Ring
            SizedBox(
              height: 60, width: 60,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  backgroundColor: theme.colorScheme.surface,
                  color: color,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            // Inner Core
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.surface,
              child: Icon(icon, color: color, size: 22),
            ),
            // Floating Level Badge
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                child: Text(
                  "Lv.$level",
                  style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Skill Tree", style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 1.5)), 
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkillNode(theme, "STEM", branchXp['STEM'] ?? 0, Colors.greenAccent[400]!, Icons.science),
                _buildSkillNode(theme, "HUMSS", branchXp['HUMSS'] ?? 0, Colors.orangeAccent[400]!, Icons.menu_book),
                _buildSkillNode(theme, "ABM", branchXp['ABM'] ?? 0, Colors.blueAccent[400]!, Icons.attach_money),
                _buildSkillNode(theme, "TVL", branchXp['TVL'] ?? 0, Colors.redAccent[400]!, Icons.electrical_services),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1);
  }
}

// =========================================================================
// 3. QUEST BOARD PREVIEW
// =========================================================================
class QuestBoardPreview extends ConsumerWidget {
  const QuestBoardPreview({super.key});

  Pathway? _activePathway(PathwayCatalogResponse? catalog) {
    if (catalog == null) return null;
    for (final p in catalog.pathways) {
      if (p.status == PathwayStatus.active) {
        return p;
      }
    }
    return null;
  }

  String? _nextTaskHint(Pathway pathway) {
    for (final t in pathway.tasks) {
      if (!t.isCompleted) {
        return t.description;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(pathwaysCatalogProvider);

    return catalogAsync.when(
      loading: () => _questCardShell(
        theme,
        title: '…',
        subtitle: 'Loading quest…',
        progress: null,
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(2),
      ),
      error: (error, stackTrace) => _questCardShell(
        theme,
        title: 'Pathways',
        subtitle: 'Pull to refresh',
        progress: 0,
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(2),
      ),
      data: (catalog) {
        final active = _activePathway(catalog);
        if (active == null) {
          return _questCardShell(
            theme,
            title: 'No active quest',
            subtitle: 'Enroll in Pathways',
            progress: 0,
            onTap: () => MainNavScope.maybeOf(context)?.goToTab(2),
          );
        }
        final hint = _nextTaskHint(active);
        final pct = (active.progressPercentage.clamp(0, 100)) / 100.0;
        return _questCardShell(
          theme,
          title: active.title,
          subtitle: hint ?? 'Keep going!',
          progress: pct,
          onTap: () => MainNavScope.maybeOf(context)?.goToTab(2),
        );
      },
    ).animate().fade(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _questCardShell(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required double? progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.map_rounded, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'ACTIVE QUEST',
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                height: 1.25,
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
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
    
    Color trophyColor = theme.colorScheme.tertiary;
    if (rank == 1) trophyColor = const Color(0xFFFFD700); // Pure Gold
    else if (rank == 2) trophyColor = const Color(0xFFC0C0C0); // Silver
    else if (rank == 3) trophyColor = const Color(0xFFCD7F32); // Bronze

    return GestureDetector(
      onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.tertiary.withOpacity(0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.tertiary.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.emoji_events_rounded, color: trophyColor, size: 28)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.1, duration: 1.seconds),
                Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.tertiary),
              ],
            ),
            const SizedBox(height: 12),
            Text("GLOBAL RANK", style: GoogleFonts.orbitron(fontSize: 9, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  rank != null ? "#$rank" : "--", 
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 22, color: theme.colorScheme.tertiary),
                ),
                Text(
                  " / $totalUsers", 
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.5)),
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
    
    if (recentScans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Discoveries", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)), 
            GestureDetector(
              onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
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
                          imagUrl: imageUrl ?? '', 
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
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lens.toUpperCase(), 
                              style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary, letterSpacing: 0.5) 
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