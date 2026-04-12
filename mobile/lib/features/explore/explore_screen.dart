import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 1. IMPORT ADDED

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

class _ExploreScreenState extends State<ExploreScreen> {
  static const Color _creamBg = Color(0xFFFFF8F0);
  static const Color _orangeAccent = Color(0xFFFF9800);
  static const Color _tabActiveBg = Color(0xFF4A5D6E);
  static const Color _tabBorder = Color(0xFF8FA8BC);
  static const Color _tabInactiveText = Color(0xFF757575);
  static const Color _tabActiveText = Color(0xFFE8E8E8);
  static const Color _navyTitle = Color(0xFF0B3C6A);
  static const Color _boardToggleBorder = Color(0xFF9BC4E2);
  static const Color _boardToggleSelected = Color(0xFF5F717D);

  int _segment = 0;
  /// 0 = By Grade Level, 1 = All Users (placeholder filter).
  int _leaderboardFilter = 0;

  static const List<_ExploreNotePlaceholder> _placeholders = [
    _ExploreNotePlaceholder(
      title: 'Notebooks',
      subtitle: 'blahblah',
      tag: 'STEM',
    ),
    _ExploreNotePlaceholder(
      title: 'Lab handout',
      subtitle: 'Scan from last week — review before quiz',
      tag: 'STEM',
    ),
    _ExploreNotePlaceholder(
      title: 'History timeline',
      subtitle: 'Chapter 12 summary',
      tag: 'HUMANITIES',
    ),
    _ExploreNotePlaceholder(
      title: 'Sketch ideas',
      subtitle: 'Quick doodles from the café',
      tag: 'ART',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).padding.bottom + 72;

    return Scaffold(
      backgroundColor: _creamBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _buildSegmentTabs(),
            ),
            if (_segment == 0) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchField(),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildHistoryFeed(bottomInset)),
            ] else
              Expanded(child: _buildLeaderboardsPanel(bottomInset)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTabs() {
    return Row(
      children: [
        Expanded(
          child: _SegmentTab(
            label: 'History',
            selected: _segment == 0,
            activeBg: _tabActiveBg,
            activeText: _tabActiveText,
            inactiveBorder: _tabBorder,
            inactiveText: _tabInactiveText,
            onTap: () => setState(() => _segment = 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SegmentTab(
            label: 'View Leaderboards',
            selected: _segment == 1,
            activeBg: _tabActiveBg,
            activeText: _tabActiveText,
            inactiveBorder: _tabBorder,
            inactiveText: _tabInactiveText,
            onTap: () => setState(() => _segment = 1),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your previously scanned stuff...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _orangeAccent,
            size: 28,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
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
        // 2. STAGGERED ANIMATION FOR HISTORY FEED
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
                TextSpan(
                  text: 'Top ',
                  style: TextStyle(color: _navyTitle),
                ),
                TextSpan(
                  text: 'Discoverers',
                  style: TextStyle(color: _orangeAccent),
                ),
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
              // 3. STAGGERED ANIMATION FOR LEADERBOARD FEED
              return _DiscovererRowCard(
                name: row.name,
                xpLabel: row.xpLabel,
                orangeBorder: _orangeAccent,
                trophyColor: _navyTitle,
              )
              .animate()
              .fade(duration: 600.ms, delay: (100 * index).ms)
              .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _boardToggleBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BoardFilterChip(
              label: 'By Grade Level',
              selected: _leaderboardFilter == 0,
              selectedBg: _boardToggleSelected,
              inactiveText: _tabInactiveText,
              onTap: () => setState(() => _leaderboardFilter = 0),
            ),
          ),
          Expanded(
            child: _BoardFilterChip(
              label: 'All Users',
              selected: _leaderboardFilter == 1,
              selectedBg: _boardToggleSelected,
              inactiveText: _tabInactiveText,
              onTap: () => setState(() => _leaderboardFilter = 1),
            ),
          ),
        ],
      ),
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

class _BoardFilterChip extends StatelessWidget {
  const _BoardFilterChip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.inactiveText,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedBg;
  final Color inactiveText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : inactiveText,
            ),
          ),
        ),
      ),
    );
  }
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

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.activeBg,
    required this.activeText,
    required this.inactiveBorder,
    required this.inactiveText,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeBg;
  final Color activeText;
  final Color inactiveBorder;
  final Color inactiveText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? activeBg : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? null
                : Border.all(color: inactiveBorder, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? activeText : inactiveText,
            ),
          ),
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

/// Secondary screen reachable via in-app navigation when you add real flows.
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