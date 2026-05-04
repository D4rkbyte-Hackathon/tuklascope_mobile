//explore screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import '../../../../core/widgets/gradient_scaffold.dart';

// Tab imports
import '../widgets/explore_history_tab.dart';
import '../widgets/explore_leaderboard_tab.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                children: const [
                  // 🔥 'const' means these tabs will never unnecessarily rebuild!
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