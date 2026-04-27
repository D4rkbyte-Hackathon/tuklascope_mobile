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

    return GradientScaffold(
      // 5. Wrap the FAB in Padding to push it ABOVE your custom navigation bar!
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), 
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TuklasTutorScreen()),
          ),
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: const Text("Ask Tutor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
      ),
      
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          onRefresh: () async => ref.refresh(homeStatsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                // Added extra bottom padding so the last item isn't hidden by the navbar
                padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, MediaQuery.paddingOf(context).bottom + 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    HomeHeader(
                      userName: userName, 
                      heroTitle: heroTitle, 
                      xp: xp,
                      avatarUrl: avatarUrl,
                    ),
                    const SizedBox(height: 24),

                    // Daily motivation no longer needs scans count
                    DailyMotivation(streak: streak),
                    const SizedBox(height: 48),

                    const HeroScanButton(),
                    const SizedBox(height: 48),

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