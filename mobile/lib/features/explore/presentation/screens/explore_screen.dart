import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 

// Core imports (Adjust the '../' depending on your exact folder depth)
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/services/scan_service.dart';

// Your newly separated widget imports!
import '../widgets/scan_history_card.dart';
import '../widgets/discoverer_row_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _filterTabController;

  // 🚀 REAL LEADERBOARD STATE VARIABLES
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoadingLeaderboard = true;
  int _currentFilterIndex = 0; // 0 = Grade Level, 1 = All Users

  // 🚀 SCAN HISTORY STATE VARIABLES
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoadingScanHistory = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _filterTabController = TabController(length: 2, vsync: this);
    
    // FETCH DATA WHEN SCREEN LOADS
    _fetchLeaderboard();
    _fetchScanHistory();

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
      
      // Start building the query
      var query = Supabase.instance.client
          .from('profiles')
          .select('id, full_name, total_xp, education_level')
          .order('total_xp', ascending: false) // Highest XP first
          .limit(50); // Top 50

      // If they clicked "By Grade Level", filter the query!
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
              .eq('education_level', myGrade) // FILTER APPLIED HERE
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

  // 🚀 FETCH SCAN HISTORY FROM SUPABASE
  Future<void> _fetchScanHistory() async {
    setState(() => _isLoadingScanHistory = true);
    
    try {
      final scans = await ScanService.getUserScanHistory(limit: 100);
      
      if (mounted) {
        setState(() {
          _scanHistory = scans;
          _isLoadingScanHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
      if (mounted) setState(() => _isLoadingScanHistory = false);
    }
  }

  // Get filtered scans based on search query
  List<Map<String, dynamic>> _getFilteredScans() {
    if (_searchQuery.isEmpty) {
      return _scanHistory;
    }
    
    return _scanHistory
        .where((scan) =>
            (scan['object_name'] as String?)
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false)
        .toList();
  }

  // 🚀 HELPER TO COLOR TROPHIES GOLD, SILVER, BRONZE
  Color _getTrophyColor(int index, ThemeData theme) {
    if (index == 0) return Colors.amber; // 1st Place
    if (index == 1) return Colors.blueGrey[300]!; // 2nd Place
    if (index == 2) return const Color(0xFFCD7F32); // 3rd Place (Bronze)
    return theme.colorScheme.onSurface.withValues(alpha: 0.3); // Everyone else
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _buildMainSegmentTabs(theme),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // VIEW 1: History
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSearchField(theme),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildHistoryFeed(bottomInset, theme)),
                    ],
                  ),
                  
                  // VIEW 2: Leaderboards
                  _buildLeaderboardsPanel(bottomInset, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ANIMATED TAB BARS
  // ===========================================================================

  Widget _buildMainSegmentTabs(ThemeData theme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface Background
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1.2), // Themed Border
      ),
      child: TabBar(
        controller: _mainTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent, // Hides default underline
        indicator: BoxDecoration(
          color: theme.colorScheme.secondary, // Themed Orange Highlight
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: theme.colorScheme.onSecondary, // Text color matches the highlight's text requirement
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed Unselected Text
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'View Leaderboards'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardFilterToggle(ThemeData theme) {
    return Container(
      height: 44, // Slightly smaller than main tabs
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface Background
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1.2), // Themed Border
      ),
      child: TabBar(
        controller: _filterTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.9), // Themed Blue Highlight
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: theme.colorScheme.onPrimary, // Ensures contrast on the blue highlight
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), // Themed Unselected Text
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'By Grade Level'),
          Tab(text: 'All Users'),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONTENT WIDGETS
  // ===========================================================================

  Widget _buildSearchField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: isDark ? 0 : 1, // Shadow invisible in dark mode anyway
      shadowColor: theme.shadowColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface, // Themed Input Surface
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: TextStyle(color: theme.colorScheme.onSurface), // Themed Input Text
        decoration: InputDecoration(
          hintText: 'Search your previously scanned stuff...',
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15), // Themed Hint Text
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.secondary, size: 28), // Themed Orange Icon
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            // Render a slight border in dark mode to separate it from the dark background
            borderSide: isDark ? BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)) : BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildHistoryFeed(double bottomInset, ThemeData theme) {
    // Show loading indicator
    if (_isLoadingScanHistory) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }

    // Get filtered scans
    final filteredScans = _getFilteredScans();

    // Show empty state if no scans
    if (filteredScans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No scans yet'
                  : 'No results for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Show real scan history
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredScans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final scan = filteredScans[index];
        final objectName = scan['object_name'] as String? ?? 'Unknown Item';
        final lens = scan['chosen_lens'] as String? ?? 'STEM';
        final createdAt = scan['created_at'] as String?;
        final imageUrl = scan['image_url'] as String?;

        // Format date
        String formattedDate = 'Recently';
        if (createdAt != null) {
          try {
            final date = DateTime.parse(createdAt);
            final now = DateTime.now();
            final difference = now.difference(date);

            if (difference.inDays == 0) {
              formattedDate = 'Today';
            } else if (difference.inDays == 1) {
              formattedDate = 'Yesterday';
            } else if (difference.inDays < 7) {
              formattedDate = '${difference.inDays}d ago';
            } else {
              formattedDate = '${(difference.inDays / 7).toStringAsFixed(0)}w ago';
            }
          } catch (e) {
            formattedDate = 'Recently';
          }
        }

        // USING THE SEPARATED WIDGET HERE
        return ScanHistoryCard(
          title: objectName,
          subtitle: formattedDate,
          tag: lens,
          imageUrl: imageUrl,
          accent: theme.colorScheme.secondary,
        )
        .animate()
        .fade(duration: 600.ms, delay: (100 * index).ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
      },
    );
  }

  Widget _buildLeaderboardsPanel(double bottomInset, ThemeData theme) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'Top ', style: TextStyle(color: theme.colorScheme.primary)), // Themed Blue
                TextSpan(text: 'Discoverers', style: TextStyle(color: theme.colorScheme.secondary)), // Themed Orange
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLeaderboardFilterToggle(theme),
        ),
        const SizedBox(height: 18),
        
        // 🚀 REAL DATA BUILDER
        Expanded(
          child: _isLoadingLeaderboard
            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary)) // Themed Loader
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
                    
                    // Format data safely
                    final name = user['full_name'] ?? 'Anonymous Explorer';
                    final xp = user['total_xp'] ?? 0;
                    final displayName = isMe ? '$name (You)' : name;

                    // USING THE SEPARATED WIDGET HERE
                    return DiscovererRowCard(
                      name: displayName,
                      xpLabel: '$xp XP',
                      orangeBorder: isMe ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1), // Highlight current user
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
}

// Kept this so routing doesn't break if you currently call it anywhere!
// If you don't use it in your app router, you can safely delete it too.
class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Themed Background
      appBar: AppBar(
        title: const Text('Leaderboards'),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface, // Themed Header
        elevation: 0,
      ),
      body: const Center(
        child: Text('Screen 6.2: Leaderboards (placeholder)'),
      ),
    );
  }
}