import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS

import '../../core/widgets/gradient_scaffold.dart';

import 'providers/home_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/daily_motivation.dart';
import 'widgets/hero_scan_button.dart';
import 'widgets/home_preview_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(homeStatsProvider);

    final userName = statsAsync.value?.userName ?? '...';
    final heroTitle = statsAsync.value?.heroTitle ?? '...';
    final xp = statsAsync.value?.totalPoints ?? 0;
    final streak = statsAsync.value?.dailyStreak ?? 0;
    final avatarUrl = statsAsync.value?.avatarUrl;

    final branchXp =
        statsAsync.value?.branchXp ??
        {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0};
    final userRank = statsAsync.value?.userRank;
    final totalUsers = statsAsync.value?.totalUsers ?? 0;

    // Extract Recent Scans
    final recentScans = statsAsync.value?.recentScans ?? [];

    return GradientScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          onRefresh: () async => ref.refresh(homeStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  20.0,
                  16.0,
                  MediaQuery.paddingOf(context).bottom + 80,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    HomeHeader(
                      userName: userName,
                      heroTitle: heroTitle,
                      xp: xp,
                      avatarUrl: avatarUrl,
                    ),
                    const SizedBox(height: 24),

                    DailyMotivation(streak: streak),
                    const SizedBox(height: 48),

                    const HeroScanButton(),
                    const SizedBox(height: 48),

                    RecentDiscoveriesSection(recentScans: recentScans),
                    if (recentScans.isNotEmpty) const SizedBox(height: 32),

                    const QuickRecommendationCard(),
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

                    // 🚀 The Static Tutor Banner was intentionally removed from here.
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}