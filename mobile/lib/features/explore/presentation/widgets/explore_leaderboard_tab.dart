import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'discoverer_row_card.dart';

class ExploreLeaderboardTab extends StatefulWidget {
  const ExploreLeaderboardTab({super.key});

  @override
  State<ExploreLeaderboardTab> createState() => _ExploreLeaderboardTabState();
}

class _ExploreLeaderboardTabState extends State<ExploreLeaderboardTab> with SingleTickerProviderStateMixin {
  late TabController _filterTabController;

  // 🚀 REAL LEADERBOARD STATE VARIABLES
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoadingLeaderboard = true;
  int _currentFilterIndex = 0; // 0 = Grade Level, 1 = All Users

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 2, vsync: this);
    
    _fetchLeaderboard();

    // RE-FETCH WHEN FILTER TAB CHANGES
    _filterTabController.addListener(() {
      if (_filterTabController.index != _currentFilterIndex) {
        _currentFilterIndex = _filterTabController.index;
        _fetchLeaderboard();
      }
    });
  }

  // 🚀 THE FUNCTION TO GET REAL SCORES FROM SUPABASE
  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoadingLeaderboard = true);
    
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      var query = Supabase.instance.client
          .from('profiles')
          .select('id, full_name, total_xp, education_level')
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
              .select('id, full_name, total_xp, education_level')
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
        const SizedBox(height: 18),
        
        Expanded(
          child: _isLoadingLeaderboard
            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary)) 
            : _leaderboardData.isEmpty
              ? Center(child: Text('No explorers found.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))))
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _leaderboardData.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = _leaderboardData[index];
                    final isMe = user['id'] == currentUserId;
                    
                    final name = user['full_name'] ?? 'Anonymous Explorer';
                    final xp = user['total_xp'] ?? 0;
                    final displayName = isMe ? '$name (You)' : name;

                    return DiscovererRowCard(
                      name: displayName,
                      xpLabel: '$xp XP',
                      orangeBorder: isMe ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      trophyColor: _getTrophyColor(index, theme),
                      rank: index + 1,
                    )
                    .animate(key: ValueKey('leaderboard_${_filterTabController.index}_$index'))
                    .fade(duration: 600.ms, delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * index).ms);
                  },
                ),
        ),
      ],
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