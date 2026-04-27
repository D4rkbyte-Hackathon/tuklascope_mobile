import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../scanner/tuklas_tutor_screen.dart';

// Import our new extracted components
import 'providers/home_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/daily_motivation.dart';
import 'widgets/hero_scan_button.dart';
// Note: Assumes you put the Recommendation, Skill Tree, and Leaderboard widgets into 'home_preview_cards.dart'
import 'widgets/home_preview_cards.dart'; 

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Watch our newly separated provider
    final statsAsync = ref.watch(homeStatsProvider);

    // Extract values safely
    final userName = statsAsync.value?.userName ?? '...';
    final heroTitle = statsAsync.value?.heroTitle ?? '...';
    final xp = statsAsync.value?.totalPoints ?? 0;
    final streak = statsAsync.value?.dailyStreak ?? 0;
    final scans = statsAsync.value?.todayScansCount ?? 0;

    return GradientScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const TuklasTutorScreen()),
        ),
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("Ask Tutor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
      
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
                    
                    HomeHeader(userName: userName, heroTitle: heroTitle, xp: xp),
                    const SizedBox(height: 24),

                    DailyMotivation(streak: streak, scans: scans),
                    const SizedBox(height: 32),

                    const HeroScanButton(),
                    const SizedBox(height: 32),

                    // Assuming you moved the remaining widgets to home_preview_cards.dart
                    const QuickRecommendationCard(),
                    const SizedBox(height: 24),

                    const MiniSkillTreeCard(),
                    const SizedBox(height: 24),

                    Row(
                      children: const [
                        Expanded(child: QuestBoardPreview()),
                        SizedBox(width: 16),
                        Expanded(child: LeaderboardTeaser()),
                      ],
                    ),
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