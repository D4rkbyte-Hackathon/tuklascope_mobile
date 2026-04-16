import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import '../../core/widgets/gradient_scaffold.dart';

/// Placeholder model until user uploads / API are wired.
class _ExploreNotePlaceholder {
  const _ExploreNotePlaceholder({
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  final String title;
  final String subtitle;
  final String tag;
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

// 1. ADDED TickerProviderStateMixin for the multiple TabControllers
class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  static const Color _orangeAccent = Color(0xFFFF6B2C);
  static const Color _tabBorder = Color(0xFF8FA8BC);
  static const Color _tabInactiveText = Color(0xFF757575);
  static const Color _navyTitle = Color(0xFF0B3C6A);
  static const Color _boardToggleBorder = Color(0xFF9BC4E2);
  static const Color _boardToggleSelected = Color(0xFF5F717D);

  // 2. REPLACED INT SEGMENTS WITH TAB CONTROLLERS
  late TabController _mainTabController;
  late TabController _filterTabController;

  static const List<_ExploreNotePlaceholder> _placeholders = [
    _ExploreNotePlaceholder(title: 'Notebooks', subtitle: 'blahblah', tag: 'STEM'),
    _ExploreNotePlaceholder(title: 'Lab handout', subtitle: 'Scan from last week — review before quiz', tag: 'STEM'),
    _ExploreNotePlaceholder(title: 'History timeline', subtitle: 'Chapter 12 summary', tag: 'HUMANITIES'),
    _ExploreNotePlaceholder(title: 'Sketch ideas', subtitle: 'Quick doodles from the café', tag: 'ART'),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _filterTabController = TabController(length: 2, vsync: this);
    
    // Add listener to filter tab so we can rebuild the list if necessary in the future
    _filterTabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _buildMainSegmentTabs(),
            ),
            
            // 3. ADDED TABBARVIEW FOR SWIPEABLE MAIN SCREENS
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
                        child: _buildSearchField(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildHistoryFeed(bottomInset)),
                    ],
                  ),
                  
                  // VIEW 2: Leaderboards
                  _buildLeaderboardsPanel(bottomInset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // THE NEW ANIMATED TAB BARS
  // ===========================================================================

  Widget _buildMainSegmentTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _tabBorder, width: 1.2),
      ),
      child: TabBar(
        controller: _mainTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent, // Hides default underline
        indicator: BoxDecoration(
          color: _orangeAccent,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _tabInactiveText,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'View Leaderboards'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardFilterToggle() {
    return Container(
      height: 44, // Slightly smaller than main tabs
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _boardToggleBorder, width: 1.2),
      ),
      child: TabBar(
        controller: _filterTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: _boardToggleSelected,
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _tabInactiveText,
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

  Widget _buildSearchField() {
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your previously scanned stuff...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: _orangeAccent, size: 28),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildHistoryFeed(double bottomInset) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      itemCount: _placeholders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _placeholders[index];
        return _NoteCard(
          title: item.title,
          subtitle: item.subtitle,
          tag: item.tag,
          accent: _orangeAccent,
        )
        .animate()
        .fade(duration: 600.ms, delay: (100 * index).ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
      },
    );
  }

  Widget _buildLeaderboardsPanel(double bottomInset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'Top ', style: TextStyle(color: _navyTitle)),
                TextSpan(text: 'Discoverers', style: TextStyle(color: _orangeAccent)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLeaderboardFilterToggle(),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
            physics: const BouncingScrollPhysics(),
            itemCount: _discovererPlaceholders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final row = _discovererPlaceholders[index];
              return _DiscovererRowCard(
                name: row.name,
                xpLabel: row.xpLabel,
                orangeBorder: _orangeAccent,
                trophyColor: _navyTitle,
              )
              // Added key so animations replay when filter tab is switched
              .animate(key: ValueKey('leaderboard_${_filterTabController.index}_$index'))
              .fade(duration: 600.ms, delay: (50 * index).ms)
              .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * index).ms);
            },
          ),
        ),
      ],
    );
  }

  static const List<_DiscovererPlaceholder> _discovererPlaceholders = [
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
    _DiscovererPlaceholder(name: 'Juan Dela Cruz', xpLabel: '67, 420 XP'),
  ];
}

class _DiscovererPlaceholder {
  const _DiscovererPlaceholder({
    required this.name,
    required this.xpLabel,
  });

  final String name;
  final String xpLabel;
}

class _DiscovererRowCard extends StatelessWidget {
  const _DiscovererRowCard({
    required this.name,
    required this.xpLabel,
    required this.orangeBorder,
    required this.trophyColor,
  });

  final String name;
  final String xpLabel;
  final Color orangeBorder;
  final Color trophyColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: orangeBorder, width: 1.4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE0E0E0),
              child: Icon(Icons.person, size: 32, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    xpLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.emoji_events_outlined, size: 30, color: trophyColor),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: Container(
              height: 168,
              color: Colors.grey.shade300,
              child: Icon(
                Icons.photo_outlined,
                size: 56,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keeping this so routing doesn't break if you call it anywhere!
class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Leaderboards'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Screen 6.2: Leaderboards (placeholder)'),
      ),
    );
  }
}