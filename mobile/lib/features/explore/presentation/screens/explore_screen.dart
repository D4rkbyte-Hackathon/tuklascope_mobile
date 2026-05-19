//explore screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import '../../../../core/widgets/gradient_scaffold.dart';

// Tab imports
import '../widgets/explore_history_tab.dart';
import '../widgets/explore_leaderboard_tab.dart';

/// Lets [MainNavigation] switch Explore sub-tabs without a [GlobalKey].
///
/// Explore may not be mounted until the user opens that bottom tab, so
/// [requestLeaderboard] stores a pending flag consumed in [ExploreScreen.initState].
class ExploreTabController {
  TabController? _tabController;
  bool _pendingLeaderboard = false;

  void bind(TabController controller) {
    _tabController = controller;
  }

  void unbind() {
    _tabController = null;
  }

  /// Returns whether the next [ExploreScreen] mount should start on leaderboards.
  bool consumePendingLeaderboard() {
    if (!_pendingLeaderboard) return false;
    _pendingLeaderboard = false;
    return true;
  }

  void requestLeaderboard() {
    _pendingLeaderboard = true;

    final controller = _tabController;
    if (controller == null) return;

    _pendingLeaderboard = false;
    if (controller.index != 1) {
      controller.animateTo(1);
    }
  }
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.tabController});

  final ExploreTabController? tabController;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    final startOnLeaderboard =
        widget.tabController?.consumePendingLeaderboard() ?? false;
    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: startOnLeaderboard ? 1 : 0,
    );
    widget.tabController?.bind(_mainTabController);
  }

  @override
  void dispose() {
    widget.tabController?.unbind();
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      resizeToAvoidBottomInset: false,
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
                // 💥 FIX: Disable inner swiping so the Main PageView gets all the swipes
                physics: const NeverScrollableScrollPhysics(), 
                children: const [
                  ExploreHistoryTab(),
                  ExploreLeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSegmentTabs(ThemeData theme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1.2), 
      ),
      child: TabBar(
        controller: _mainTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent, 
        indicator: BoxDecoration(
          color: theme.colorScheme.secondary, 
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: theme.colorScheme.onSecondary, 
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'View Leaderboards'),
        ],
      ),
    );
  }
}