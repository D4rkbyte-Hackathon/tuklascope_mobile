// ignore_for_file: deprecated_member_use

import 'dart:ui';

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
    if (rank == 1) {
      trophyColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      trophyColor = const Color(0xFFC0C0C0);
    }
    else if (rank == 3) {
      trophyColor = const Color(0xFFCD7F32);
    }

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
// 5. RECENT DISCOVERIES SECTION (OPTIMIZED HORIZONTAL LIST)
// =========================================================================
class RecentDiscoveriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentScans;

  const RecentDiscoveriesSection({super.key, required this.recentScans});

  Color _getLensColor(String lens) {
    switch (lens.toUpperCase()) {
      case 'STEM': return Colors.greenAccent[400]!;
      case 'HUMSS': return Colors.orangeAccent[400]!;
      case 'ABM': return Colors.blueAccent[400]!;
      case 'TVL': return Colors.redAccent[400]!;
      default: return Colors.purpleAccent[400]!;
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return "Recently";
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inHours < 24) return "${diff.inHours == 0 ? 1 : diff.inHours}h ago";
      if (diff.inDays == 1) return "Yesterday";
      return "${date.month}/${date.day}/${date.year}";
    } catch (e) {
      return "Recently";
    }
  }

  /// Groups scans with the same object name (different strands) into one card,
  /// matching explore history tab behavior.
  List<Map<String, dynamic>> _mergeScansByObjectName(
    List<Map<String, dynamic>> scans, {
    int maxItems = 3,
  }) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final scan in scans) {
      final name = (scan['object_name'] as String? ?? 'unknown').trim().toLowerCase();
      grouped.putIfAbsent(name, () => []).add(scan);
    }

    final List<Map<String, dynamic>> merged = [];
    for (final list in grouped.values) {
      list.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
      final representative = list.first;
      final clone = Map<String, dynamic>.from(representative);
      clone['related_scans'] = list;
      merged.add(clone);
    }

    merged.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return merged.take(maxItems).toList();
  }

  static const _strandOrder = ['STEM', 'ABM', 'HUMSS', 'TVL'];

  List<String> _sortedTags(List<String> tags) {
    final normalized = tags.map((t) => t.toUpperCase()).toSet().toList();
    normalized.sort((a, b) {
      final ai = _strandOrder.indexOf(a);
      final bi = _strandOrder.indexOf(b);
      return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
    });
    return normalized;
  }

  Widget _buildStrandChip(String lens) {
    final color = _getLensColor(lens);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.55), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.9), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            lens.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrandTagsCluster(List<String> tags) {
    final sorted = _sortedTags(tags);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: sorted.map(_buildStrandChip).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayScans = _mergeScansByObjectName(recentScans);

    if (displayScans.isEmpty) return const SizedBox.shrink();

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
        // 🚀 UX FIX: Removed IntrinsicHeight. Defined explicit fixed dimensions for 60fps scrolling.
        SizedBox(
          height: 220, // Tall aspect ratio to match ScanHistoryCard
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none, 
            itemCount: displayScans.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final scan = displayScans[index];
              final objectName = scan['object_name'] as String? ?? 'Unknown';
              final imageUrl = scan['image_url'] as String?;
              final lens = scan['chosen_lens'] as String? ?? 'STEM';
              final scanId = scan['id'] as String? ?? '';
              final timeStr = _formatDate(scan['created_at'] as String?);
              final accentColor = _getLensColor(lens);
              final relatedScans = scan['related_scans'] as List<Map<String, dynamic>>?;
              final tags = relatedScans != null
                  ? relatedScans.map((s) => s['chosen_lens'] as String? ?? 'STEM').toSet().toList()
                  : [lens];

              return GestureDetector(
                onTap: () {
                  if (scanId.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScanDetailScreen(
                          scanId: scanId,
                          objectName: objectName,
                          imagUrl: imageUrl ?? '',
                          relatedScans: relatedScans,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 150, 
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image
                        imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.contain)
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.science, color: accentColor.withOpacity(0.5), size: 40),
                              ),
                        
                        // Dark Overlay Gradient (Better contrast for white text)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),

                        // Strand tags (Top Right)
                        Positioned(
                          top: 8,
                          right: 8,
                          left: 8,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _buildStrandTagsCluster(tags),
                          ),
                        ),

                        // Title & Time (Bottom)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                objectName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.timeline, size: 10, color: Colors.white.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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