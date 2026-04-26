import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'discoverer_row_card.dart';
import 'leaderboard_podium.dart'; // 🚀 NEW
import 'discoverer_profile_sheet.dart'; // 🚀 NEW

class ExploreLeaderboardTab extends StatefulWidget {
  const ExploreLeaderboardTab({super.key});

  @override
  State<ExploreLeaderboardTab> createState() => _ExploreLeaderboardTabState();
}

class _ExploreLeaderboardTabState extends State<ExploreLeaderboardTab> with SingleTickerProviderStateMixin {
  late TabController _filterTabController;

  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoadingLeaderboard = true;
  int _currentFilterIndex = 0; 

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 2, vsync: this);
    _fetchLeaderboard();

    _filterTabController.addListener(() {
      if (_filterTabController.index != _currentFilterIndex) {
        _currentFilterIndex = _filterTabController.index;
        _fetchLeaderboard();
      }
    });
  }

  // 🚀 1. UPDATED QUERY to fetch avatar_url and bio
  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoadingLeaderboard = true);
    
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      // Added avatar_url and bio to the select statement!
      var query = Supabase.instance.client
          .from('profiles')
          .select('id, full_name, total_xp, education_level, profile_picture_url, bio, country, city, current_streak, current_level')
          .order('total_xp', ascending: false) 
          .limit(50); 

      if (_currentFilterIndex == 0 && currentUser != null) {
        final myProfile = await Supabase.instance.client
            .from('profiles')
            .select('education_level')
            .eq('id', currentUser.id)
            .maybeSingle();

        final myGrade = myProfile?['education_level'];
        
        if (myGrade != null && myGrade.isNotEmpty) {
          query = Supabase.instance.client
              .from('profiles')
              .select('id, full_name, total_xp, education_level, profile_picture_url, bio, country, city, current_streak, current_level')
              .eq('education_level', myGrade) 
              .order('total_xp', ascending: false)
              .limit(50);
        }
      }

      final response = await query;
      
      if (mounted) {
        setState(() {
          _leaderboardData = List<Map<String, dynamic>>.from(response);
          _isLoadingLeaderboard = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    }
  }

  // 🚀 2. BOTTOM SHEET TRIGGER
  void _showUserProfile(Map<String, dynamic> user, int rank) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = user['id'] == currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to be sized by content
      backgroundColor: Colors.transparent, // Let our custom widget handle corners
      builder: (context) => DiscovererProfileSheet(
        user: user,
        rank: rank,
        isMe: isMe,
      ),
    );
  }

  Color _getTrophyColor(int index, ThemeData theme) {
    if (index == 0) return Colors.amber; 
    if (index == 1) return Colors.blueGrey[300]!; 
    if (index == 2) return const Color(0xFFCD7F32); 
    return theme.colorScheme.onSurface.withValues(alpha: 0.3); 
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.15),
              children: [
                TextSpan(text: 'Top ', style: TextStyle(color: theme.colorScheme.primary)), 
                TextSpan(text: 'Discoverers', style: TextStyle(color: theme.colorScheme.secondary)), 
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLeaderboardFilterToggle(theme),
        ),
        
        Expanded(
          child: _isLoadingLeaderboard
            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary)) 
            : _leaderboardData.isEmpty
              ? Center(child: Text('No explorers found.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))))
              : _buildGamifiedList(currentUserId, bottomInset, theme), // 🚀 3. CALLED NEW METHOD
        ),
      ],
    );
  }

  // 🚀 4. BUILD LIST WITH PODIUM AT THE TOP
  Widget _buildGamifiedList(String? currentUserId, double bottomInset, ThemeData theme) {
    // Split the data!
    final top3 = _leaderboardData.take(3).toList();
    final remaining = _leaderboardData.skip(3).toList();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      // Add +1 to length if we have a podium to show
      itemCount: remaining.length + (top3.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        
        // If it's the very first item, render the Podium!
        if (index == 0 && top3.isNotEmpty) {
          return LeaderboardPodium(
            topUsers: top3,
            onUserTap: _showUserProfile,
          ).animate().fade(duration: 600.ms).slideY(begin: 0.1);
        }

        // Adjust index for the remaining users list
        final remainingIndex = top3.isNotEmpty ? index - 1 : index;
        final user = remaining[remainingIndex];
        final actualRank = remainingIndex + 4; // Ranks start at 4 because 1-3 are on podium
        
        final isMe = user['id'] == currentUserId;
        final name = user['full_name'] ?? 'Anonymous Explorer';
        final xp = user['total_xp'] ?? 0;
        final displayName = isMe ? '$name (You)' : name;
        
        // 🚀 Extract avatar
        final avatarUrl = user['profile_picture_url'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DiscovererRowCard(
            name: displayName,
            xpLabel: '$xp XP',
            avatarUrl: avatarUrl, // 🚀 Pass it to the card
            orangeBorder: isMe ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            trophyColor: theme.colorScheme.onSurface.withValues(alpha: 0.3), // Everyone here gets grey
            rank: actualRank,
            onTap: () => _showUserProfile(user, actualRank), 
          )
          .animate(key: ValueKey('leaderboard_${_filterTabController.index}_$actualRank'))
          .fade(duration: 600.ms, delay: (50 * remainingIndex).ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * remainingIndex).ms),
        );
      },
    );
  }

  Widget _buildLeaderboardFilterToggle(ThemeData theme) {
    return Container(
      height: 44, 
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1.2), 
      ),
      child: TabBar(
        controller: _filterTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.9), 
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: theme.colorScheme.onPrimary, 
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'By Grade Level'),
          Tab(text: 'All Users'),
        ],
      ),
    );
  }
}