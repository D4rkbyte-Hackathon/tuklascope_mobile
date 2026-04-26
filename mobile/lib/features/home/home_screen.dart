import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../../core/navigation/main_nav_scope.dart';
import '../scanner/tuklas_tutor_screen.dart';

// =========================================================================
// STATE MANAGEMENT: HOME STATS PROVIDER
// =========================================================================

class HomeStats {
  final int dailyStreak;
  final int totalPoints;
  final int todayScansCount;

  HomeStats({
    required this.dailyStreak,
    required this.totalPoints,
    required this.todayScansCount,
  });
}

// TECH LEAD: This provider fetches real data from Supabase for the current user.
final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return HomeStats(dailyStreak: 0, totalPoints: 0, todayScansCount: 0);
  }

  // 1. Fetch Profile Data (Streak & Total XP)
  final profileData = await client
      .from('profiles')
      .select('current_streak, total_xp')
      .eq('id', userId)
      .maybeSingle();

  // 2. Fetch Today's Scans Count for the Daily Quest (0/3)
  final today = DateTime.now();
  // Get local midnight, convert it to a UTC DateTime, and safely format to ISO with the 'Z'
  final startOfDay = DateTime(
    today.year,
    today.month,
    today.day,
  ).toUtc().toIso8601String();

  final scansData = await client
      .from('scans')
      .select('id')
      .eq('user_id', userId)
      .gte('created_at', startOfDay);

  return HomeStats(
    dailyStreak: profileData?['current_streak'] ?? 0,
    totalPoints: profileData?['total_xp'] ?? 0,
    todayScansCount: (scansData as List).length,
  );
});

// =========================================================================
// UI SCREEN
// =========================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Dynamically grab the theme!
    final isDark = theme.brightness == Brightness.dark;

    // TECH LEAD: Watch the provider to get real-time stats
    final statsAsync = ref.watch(homeStatsProvider);

    // Dynamic brand colors for specific feature cards
    const mainGreen = Color(0xFF4CAF50); // From your color palette
    final adaptivePurple = isDark
        ? const Color(0xFFCE93D8)
        : const Color(0xFF8E24AA); // Lightens in dark mode

    final List<Widget> listItems = [
      _buildDailyQuestCard(statsAsync, theme),
      const SizedBox(height: 32),

      _buildHeroHeading('Discover', 'Everything', theme),
      const SizedBox(height: 16),

      Text(
        'Transform any object around you into a learning adventure. Take a photo and unlock the science behind everyday life!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8), // Themed
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 32),

      _buildInfoCard(
        theme: theme,
        title: 'Tuklas-Araw',
        description:
            'Explore the science behind Filipino rice terraces - How do these ancient structures demonstrate physics and engineering?',
        borderColor: theme.colorScheme.secondary,
        buttonText: 'Ask TuklasTutor about this →',
        buttonGradient: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8),
        ],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TuklasTutorScreen()),
        ),
      ),
      const SizedBox(height: 24),

      _buildDiscoverySection(theme),
      const SizedBox(height: 48),

      _buildHeroHeading(
        'Explore Your',
        'Learning\nJourney',
        theme,
        isStacked: true,
      ),
      const SizedBox(height: 16),

      Text(
        'Track your progress, discover new pathways, and get personalized guidance for your academic journey.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8), // Themed
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 32),

      _buildFeatureCard(
        theme: theme,
        title: 'Learning Pathways',
        description:
            'Structured learning journeys\nfrom beginner to advanced levels',
        borderColor: theme.colorScheme.primary,
        buttonText: 'Explore Pathways →',
        buttonTextColor: theme.colorScheme.primary,
        iconArea: Icon(
          Icons.map_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(2),
      ),
      const SizedBox(height: 24),

      _buildFeatureCard(
        theme: theme,
        title: 'The "Kaalaman" Skill Tree',
        description:
            'Track your progress, discover new pathways,\nand get personalized guidance for your journey.',
        borderColor: mainGreen,
        buttonText: 'View Pathfinder →',
        buttonTextColor: mainGreen,
        iconArea: const Icon(Icons.account_tree_outlined, size: 64, color: mainGreen),
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
      ),
      const SizedBox(height: 24),

      _buildFeatureCard(
        theme: theme,
        title: 'Tuklascope AI',
        description:
            'Get personalized career and academic\nguidance based on your skills',
        borderColor: adaptivePurple,
        buttonText: 'Get Guidance →',
        buttonTextColor: adaptivePurple,
        iconArea: Icon(
          Icons.auto_awesome_outlined,
          size: 64,
          color: adaptivePurple,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TuklasTutorScreen()),
        ),
      ),
      const SizedBox(height: 60),
    ];

    return GradientScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // RefreshIndicator allows pull-to-refresh
            RefreshIndicator(
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              onRefresh: () async {
                // TECH LEAD: This forces the provider to run the Supabase query again!
                return ref.refresh(homeStatsProvider.future);
              },
              child: ListView.builder(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Changed to allow pulling even if list is short
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  20.0,
                  16.0,
                  MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  final item = listItems[index];
                  if (item is SizedBox) return item;

                  return item
                      .animate()
                      .fade(duration: 600.ms, delay: (50 * (index % 10)).ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                        delay: (50 * (index % 10)).ms,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildDailyQuestCard(
    AsyncValue<HomeStats> statsAsync,
    ThemeData theme,
  ) {
    final streak = statsAsync.value?.dailyStreak ?? 0;
    final points = statsAsync.value?.totalPoints ?? 0;
    final scansCount = statsAsync.value?.todayScansCount ?? 0;
    final isLoading = statsAsync.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05), // Themed Shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Daily Discovery Quest',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary, // Themed Blue
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.8,
              ), // High contrast pill background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: isLoading
                      ? SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            color: theme
                                .colorScheme
                                .surface, // Matches the inverted text color
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '$scansCount/3 Discovered',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme
                                .colorScheme
                                .surface, // Always contrasts with the pill background
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    isLoading
                        ? SizedBox(
                            height: 33,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.secondary,
                            ),
                          )
                        : Text(
                            '$streak',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color:
                                  theme.colorScheme.secondary, // Themed Orange
                            ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily Streak',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ), // Themed label
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ), // Themed divider
              Expanded(
                child: Column(
                  children: [
                    isLoading
                        ? SizedBox(
                            height: 33,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Text(
                            '$points',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary, // Themed Blue
                            ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Points',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ), // Themed label
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeading(
    String part1,
    String part2,
    ThemeData theme, {
    bool isStacked = false,
  }) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: '$part1 ',
            style: TextStyle(color: theme.colorScheme.primary), // Themed Blue
          ),
          if (isStacked)
            TextSpan(
              text: '\n$part2',
              style: TextStyle(
                color: theme.colorScheme.secondary,
              ), // Themed Orange
            )
          else
            TextSpan(
              text: part2,
              style: TextStyle(
                color: theme.colorScheme.secondary,
              ), // Themed Orange
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required String title,
    required String description,
    required Color borderColor,
    required String buttonText,
    required List<Color> buttonGradient,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: borderColor, // Adopts the accent color dynamically
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface, // Themed Text
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildGradientButton(buttonText, buttonGradient, onTap: onTap),
        ],
      ),
    );
  }

  Widget _buildDiscoverySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: 0.4,
          ), // Themed border
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What will you discover today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Themed Blue
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a photo or\nuse your camera to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ), // Themed Text
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          _buildGradientButton(
            'Start Discovery →',
            [
              theme.colorScheme.tertiary,
              theme.colorScheme.secondary,
            ], // Themed Orange Gradient
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            onTap: () {
              MainNavScope.maybeOf(context)?.goToTab(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required ThemeData theme,
    required String title,
    required String description,
    required Color borderColor,
    required String buttonText,
    required Color buttonTextColor,
    required Widget iconArea,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 2,
        ), // Softer border integration
      ),
      child: Column(
        children: [
          SizedBox(height: 100, child: Center(child: iconArea)),
          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // Themed Title
            ),
          ),
          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ), // Themed Desc
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      buttonTextColor, // Dynamic color (Blue, Green, or Purple)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    String text,
    List<Color> gradientColors, {
    EdgeInsetsGeometry? padding,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white, // Kept white to pop against gradients
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
