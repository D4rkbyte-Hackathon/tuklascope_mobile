import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';

import 'providers/home_provider.dart';
import '../pathways/providers/pathways_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/daily_motivation.dart';
import 'widgets/hero_scan_button.dart';
import 'widgets/home_preview_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Riverpod automatically handles the initial data fetch when ref.watch()
    // is called in the build method below. No need to force it here!
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(homeStatsProvider);

    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;

    // Optional error listening if the initial load fails
    ref.listen<AsyncValue<HomeStats>>(homeStatsProvider, (previous, next) {
      if (next.hasError && !next.isLoading && previous?.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Offline mode: Cannot fetch latest stats.'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final isInitialLoading = statsAsync.isLoading && statsAsync.value == null;

    final stats = statsAsync.value;
    final userName = stats?.userName ?? '...';
    final xp = stats?.totalPoints ?? 0;
    final streak = stats?.dailyStreak ?? 0;
    final avatarUrl = stats?.avatarUrl;

    final branchXp =
        stats?.branchXp ?? {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0};
    final userRank = stats?.userRank;
    final totalUsers = stats?.totalUsers ?? 0;
    final recentScans = stats?.recentScans ?? [];

    Widget mainContent = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HomeHeader(userName: userName, xp: xp, avatarUrl: avatarUrl),
              const SizedBox(height: 24),

              DailyMotivation(streak: streak),
              const SizedBox(height: 48),

              const HeroScanButton(),
              const SizedBox(height: 48),

              RecentDiscoveriesSection(recentScans: recentScans),
              if (recentScans.isNotEmpty) const SizedBox(height: 32),

              QuickRecommendationCard(branchXp: branchXp),
              const SizedBox(height: 24),

              MiniSkillTreeCard(branchXp: branchXp),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(child: QuestBoardPreview()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LeaderboardTeaser(
                      rank: userRank,
                      totalUsers: totalUsers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuint,
                height:
                    (isNavBarVisible ? 0.0 : 0.0) +
                    MediaQuery.paddingOf(context).bottom,
              ),
            ]),
          ),
        ),
      ],
    );

    if (isInitialLoading) {
      mainContent = mainContent
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1500.ms,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            angle: 1.0,
          );
    }

    return GradientScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          onRefresh: () async {
            // Manual pull-to-refresh will still use the silent refresh for a buttery smooth experience!
            await ref.read(homeStatsProvider.notifier).refreshSilently();
          },
          child: mainContent,
        ),
      ),
    );
  }
}
