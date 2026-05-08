//leaderboard podium
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<Map<String, dynamic>> topUsers;
  final Function(Map<String, dynamic> user, int rank) onUserTap;

  const LeaderboardPodium({
    super.key,
    required this.topUsers,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (topUsers.isEmpty) return const SizedBox.shrink();

    // Reorder for podium layout: [Rank 2, Rank 1, Rank 3]
    final rank1 = topUsers.isNotEmpty ? topUsers[0] : null;
    final rank2 = topUsers.length > 1 ? topUsers[1] : null;
    final rank3 = topUsers.length > 2 ? topUsers[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom of podium
        children: [
          if (rank2 != null) _buildPodiumSpot(context, rank2, 2, 120, Colors.blueGrey[300]!),
          if (rank1 != null) _buildPodiumSpot(context, rank1, 1, 160, Colors.amber),
          if (rank3 != null) _buildPodiumSpot(context, rank3, 3, 100, const Color(0xFFCD7F32)), // Bronze
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(BuildContext context, Map<String, dynamic> user, int rank, double height, Color color) {
    final theme = Theme.of(context);
    final name = user['full_name']?.split(' ')[0] ?? 'Explorer'; 
    final xp = user['total_xp'] ?? 0;
    
    final avatarUrl = user['profile_picture_url'];

    // Make Rank 1 slightly wider and larger
    final isFirst = rank == 1;
    final width = isFirst ? 114.0 : 90.0;
    final avatarSize = isFirst ? 38.0 : 30.0;

    return GestureDetector(
      onTap: () => onUserTap(user, rank),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Floating Crown for 1st place with pulse and shimmer
            if (isFirst) ...[
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 40)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.15, duration: 800.ms, curve: Curves.easeInOut)
                  .shimmer(delay: 1.seconds, duration: 1.seconds, color: Colors.white70),
              const SizedBox(height: 4),
            ],
            
            // Avatar with continuous levitation effect
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isFirst ? 0.6 : 0.3),
                    blurRadius: isFirst ? 15 : 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: color, width: isFirst ? 4 : 3),
              ),
              child: CircleAvatar(
                radius: avatarSize,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null 
                    ? Icon(Icons.person, color: color, size: avatarSize) 
                    : null,
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true)) // Levitation animation
            .moveY(begin: -4, end: 2, duration: (isFirst ? 1.5 : 2).seconds, curve: Curves.easeInOut),
            
            const SizedBox(height: 12),
            
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: isFirst ? 14 : 13),
            ),
            Text(
              '$xp XP',
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.secondary, 
                fontSize: 11, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),

            // FIXED: 3D Pedestal Block (Uniform borders to prevent crash!)
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                // Fix: Must use uniform Border.all when borderRadius is applied
                border: Border.all(
                  color: color.withValues(alpha: 0.6), 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isFirst ? 0.2 : 0.05),
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ],
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '$rank',
                style: GoogleFonts.orbitron(
                  fontSize: isFirst ? 36 : 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}