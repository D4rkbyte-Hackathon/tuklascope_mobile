import 'package:flutter/material.dart';

class DiscovererProfileSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  final bool isMe;

  const DiscovererProfileSheet({
    super.key,
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final name = user['full_name'] ?? 'Anonymous Explorer';
    final bio = user['bio'] ?? 'This explorer is out charting new territories and hasn\'t written a bio yet.';
    final avatarUrl = user['profile_picture_url']; 
    final grade = user['education_level'] ?? 'Unknown Grade';
    final xp = user['total_xp'] ?? 0;
    final streak = user['current_streak'] ?? 0;
    final level = user['current_level'] ?? 1;
    
    final city = user['city'];
    final country = user['country'];
    String locationText = '';
    if (city != null && country != null) {
      locationText = '$city, $country';
    } else if (country != null) {
      locationText = country;
    } else if (city != null) {
      locationText = city;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // 1. BANNER & AVATAR STACK
          // ==========================================
          SizedBox(
            height: 140,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  bottom: 40,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      // 🚀 ADDED: Premium Drag Handle
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                ),
                // 🚀 REMOVED: The "X" Close Button
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // ==========================================
          // 2. HEADER: NAME & LOCATION
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  isMe ? '$name (You)' : name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                if (locationText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        locationText,
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                
                // ==========================================
                // 3. TAGS: RANK & EDUCATION
                // ==========================================
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTag(theme, 'Rank #$rank', theme.colorScheme.secondary),
                    _buildTag(theme, grade, theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 24),
                
                // ==========================================
                // 4. STATS GRID
                // ==========================================
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(theme, Icons.auto_awesome, Colors.amber[600]!, '$xp', 'Total XP'),
                      _buildDivider(theme),
                      _buildStatColumn(theme, Icons.local_fire_department, Colors.deepOrange, '$streak', 'Day Streak'),
                      _buildDivider(theme),
                      _buildStatColumn(theme, Icons.star_rounded, theme.colorScheme.primary, 'Lv. $level', 'Current Level'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // ==========================================
                // 5. BIO SECTION
                // ==========================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bio,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          // 🚀 ADDED: +90 to clear the bottom navigation bar completely!
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 90),
        ],
      ),
    );
  }

  Widget _buildTag(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _buildStatColumn(ThemeData theme, IconData icon, Color iconColor, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(height: 40, width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1));
  }
}