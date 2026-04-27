import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../scanner/tuklas_tutor_screen.dart';

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
    
    final branchXp = statsAsync.value?.branchXp ?? {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0};
    final userRank = statsAsync.value?.userRank;
    final totalUsers = statsAsync.value?.totalUsers ?? 0;
    
    // 🚀 Extract Recent Scans
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
                padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, MediaQuery.paddingOf(context).bottom + 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    HomeHeader(userName: userName, heroTitle: heroTitle, xp: xp, avatarUrl: avatarUrl),
                    const SizedBox(height: 24),

                    DailyMotivation(streak: streak),
                    const SizedBox(height: 48),

                    const HeroScanButton(),
                    const SizedBox(height: 48),

                    // 🚀 Added the Recent Discoveries Widget here!
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
                        Expanded(child: LeaderboardTeaser(rank: userRank, totalUsers: totalUsers)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildStaticTutorBanner(context, theme),

                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticTutorBanner(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const TuklasTutorScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Stuck on a concept?", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text("Ask TuklasTutor", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.primary),
            )
          ],
        ),
      ),
    ).animate().fade(delay: 600.ms).slideY(begin: 0.1);
  }
}