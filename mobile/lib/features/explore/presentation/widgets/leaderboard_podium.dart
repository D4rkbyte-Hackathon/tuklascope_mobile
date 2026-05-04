//leaderboard podium
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          if (rank3 != null) _buildPodiumSpot(context, rank3, 3, 100, const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(BuildContext context, Map<String, dynamic> user, int rank, double height, Color color) {
    final theme = Theme.of(context);
    final name = user['full_name']?.split(' ')[0] ?? 'Explorer'; // First name only
    final xp = user['total_xp'] ?? 0;
    
    final avatarUrl = user['profile_picture_url'];

    // Make Rank 1 slightly wider and larger
    final isFirst = rank == 1;
    final width = isFirst ? 110.0 : 90.0;
    final avatarSize = isFirst ? 36.0 : 28.0;

    return GestureDetector(
      onTap: () => onUserTap(user, rank),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Crown for 1st place
            if (isFirst) ...[
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 36),
              const SizedBox(height: 4),
            ],
            
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
            ),
            const SizedBox(height: 8),
            
            // Name
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              '$xp XP',
              style: GoogleFonts.orbitron(color: theme.colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // The Physical Podium Block
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  top: BorderSide(color: color, width: 3),
                  left: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
                  right: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
                ),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '$rank',
                style: GoogleFonts.orbitron(
                  fontSize: isFirst ? 32 : 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}