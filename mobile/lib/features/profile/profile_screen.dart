// mobile/lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import '../../core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_controller.dart';
import '../auth/services/supabase_auth_service.dart';
import 'pathfinder_blueprint_sheet.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/pathfinder_service.dart';

import '../auth/presentation/widgets/auth_gate.dart';

// =========================================================================
// STATE MANAGEMENT: PROFILE STATS PROVIDER
// =========================================================================

class ProfileStats {
  final int totalXp;
  final int currentLevel;
  final int conceptsMastered;

  // 4 Main Gamification Strands
  final int stemXp;
  final int humssXp;
  final int abmXp;
  final int tvlXp;

  // Neo4j Specific Topics & Levels
  final Map<String, int> topSkills;

  ProfileStats({
    required this.totalXp,
    required this.currentLevel,
    required this.conceptsMastered,
    required this.stemXp,
    required this.humssXp,
    required this.abmXp,
    required this.tvlXp,
    required this.topSkills,
  });

  // Calculate percentage to next level (500 XP per level)
  int get progressToNextLevel {
    int xpIntoCurrentLevel = totalXp % 500;
    return ((xpIntoCurrentLevel / 500) * 100).toInt();
  }

  // Dynamic level calculator for gamification branches
  int calculateBranchLevel(int xp) => 1 + (xp ~/ 500);
}

final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((
  ref,
) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return ProfileStats(
      totalXp: 0,
      currentLevel: 1,
      conceptsMastered: 0,
      stemXp: 0,
      humssXp: 0,
      abmXp: 0,
      tvlXp: 0,
      topSkills: {},
    );
  }

  // 1. Fetch Profile Data (XP and Level)
  final profileRes = await client
      .from('profiles')
      .select('total_xp, current_level')
      .eq('id', userId)
      .maybeSingle();

  // 2. Fetch 4-Strand XP Data
  final treeRes = await client
      .from('kaalaman_skill_tree')
      .select()
      .eq('user_id', userId)
      .maybeSingle();

  // 3. Fetch Total Scans (Concepts Mastered)
  final scansRes = await client
      .from('scans')
      .select('id')
      .eq('user_id', userId);

  // 4. Fetch Neo4j Specific Topic Nodes & Levels!
  final neo4jData = await PathfinderService.getSkillWeb();
  Map<String, int> parsedTopSkills = {};
  if (neo4jData != null && neo4jData['top_skills'] != null) {
    parsedTopSkills = Map<String, int>.from(neo4jData['top_skills']);
  }

  return ProfileStats(
    totalXp: profileRes?['total_xp'] ?? 0,
    currentLevel: profileRes?['current_level'] ?? 1,
    conceptsMastered: (scansRes as List).length,
    stemXp: treeRes?['agham_math_xp'] ?? 0,
    humssXp: treeRes?['sining_wika_xp'] ?? 0,
    abmXp: treeRes?['negosyo_pamamahala_xp'] ?? 0,
    tvlXp: treeRes?['buhay_kasanayan_xp'] ?? 0,
    topSkills: parsedTopSkills,
  );
});

// =========================================================================
// MAIN SCREEN
// =========================================================================

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Cache theme
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile & Skill Tree'),
        foregroundColor: theme.colorScheme.primary, // Themed AppBar Text
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: appUserState.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        data: (appUser) {
          if (appUser == null) {
            return Center(
              child: Text(
                'Please log in.',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }

          final profile = appUser.profile;
          String location = '';
          final city = profile.city ?? '';
          final country = profile.country ?? '';
          if (city.isNotEmpty && country.isNotEmpty) {
            location = '$city, $country';
          } else {
            location = city + country;
          }

          return Column(
            children: [
              Expanded(
                child: _ProfileTabs(
                  theme: theme,
                  currentName: profile.fullName ?? 'New Explorer',
                  currentEducationLevel:
                      profile.educationLevel ?? 'Curious Mind',
                  location: location,
                  streak: profile.currentStreak,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Stateful widget just to hold the Tab Controller
class _ProfileTabs extends ConsumerStatefulWidget {
  final ThemeData theme;
  final String currentName;
  final String currentEducationLevel;
  final String location;
  final int streak;

  const _ProfileTabs({
    required this.theme,
    required this.currentName,
    required this.currentEducationLevel,
    required this.location,
    required this.streak,
  });

  @override
  ConsumerState<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends ConsumerState<_ProfileTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surface, // Themed Surface
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: widget.theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                width: 1,
              ), // Themed Border
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: widget
                    .theme
                    .colorScheme
                    .primary, // Themed Active Tab Highlight
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: widget
                  .theme
                  .colorScheme
                  .onPrimary, // Ensures text is visible on the blue tab
              unselectedLabelColor: widget.theme.colorScheme.onSurface
                  .withValues(alpha: 0.6), // Themed Unselected text
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Settings'),
                Tab(text: 'About'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(widget.theme),
              _buildSettingsTab(widget.theme),
              _buildAboutTab(widget.theme),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: PROFILE (DYNAMIC DATA OVERHAUL)
  // ---------------------------------------------------------------------------
  Widget _buildProfileTab(ThemeData theme) {
    final statsAsync = ref.watch(profileStatsProvider);

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      onRefresh: () async {
        ref.invalidate(appUserProvider);
        return ref.refresh(profileStatsProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.paddingOf(context).bottom + 88,
        ),
        children: [
          _ProfileHeaderCard(
            theme: theme,
            fullName: widget.currentName,
            educationLevel: widget.currentEducationLevel,
            location: widget.location,
            streak: widget.streak,
            onEditPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ).animate().fade(duration: 600.ms).slideY(begin: 0.1),

          Padding(
            padding: const EdgeInsets.only(top: 28, bottom: 12),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
                children: [
                  TextSpan(
                    text: 'Your ',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  TextSpan(
                    text: 'Skill Tree',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Text(
              'Inner orbit tracks overall gamification. Outer orbit dynamically maps specific Neo4j topics as you master them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),
          ),

          // THE DYNAMIC STATS CARD
          statsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            error: (e, s) => const Center(child: Text('Error loading stats')),
            data: (stats) =>
                Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _StatsGridCard(theme: theme, stats: stats),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 100.ms)
                    .slideY(begin: 0.1),
          ),

          // 🚀 THE NEW DYNAMIC 2-TIER SKILL TREE
          statsAsync.when(
            loading: () => const SizedBox(height: 250),
            error: (e, s) => const SizedBox(),
            data: (stats) =>
                Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _DynamicSkillTreeNetwork(
                        theme: theme,
                        stats: stats,
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.1),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
                _ProfilePromoCard(
                      theme: theme,
                      borderColor: theme.colorScheme.secondary,
                      title: 'Open Your Blueprint',
                      description:
                          'See how your skills map to real-world careers.',
                      buttonLabel: 'Open Pathfinder →',
                      buttonColor: theme.colorScheme.primary,
                      onPressed: () => showPathfinderBlueprintSheet(
                        context,
                        onNavigateToScan: () =>
                            MainNavScope.maybeOf(context)?.goToTab(1),
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.1),
          ),

          _ProfilePromoCard(
            theme: theme,
            borderColor: theme.colorScheme.primary.withValues(alpha: 0.35),
            title: 'Expand Your Knowledge',
            description: 'Scan new objects to add topics to your outer orbit!',
            buttonLabel: 'Start Discovery →',
            buttonColor: theme.colorScheme.secondary,
            onPressed: () => MainNavScope.maybeOf(context)?.goToTab(1),
          ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildSettingsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: appThemeNotifier,
                builder: (context, currentMode, child) {
                  final isSystemDark =
                      MediaQuery.platformBrightnessOf(context) ==
                      Brightness.dark;
                  final isDarkMode =
                      currentMode == ThemeMode.dark ||
                      (currentMode == ThemeMode.system && isSystemDark);

                  return SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    value: isDarkMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      appThemeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  );
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.vibration,
                  color: theme.colorScheme.secondary,
                ),
                title: Text(
                  'Vibration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                value: true,
                activeColor: theme.colorScheme.secondary,
                onChanged: (bool value) {},
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),

        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                trailing: Icon(Icons.logout, color: theme.colorScheme.error),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: ABOUT
  // ---------------------------------------------------------------------------
  Widget _buildAboutTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.school, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Tuklascope is a modern learning companion that helps you discover, track, and engage with educational content.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _StatsGridCard extends StatelessWidget {
  final ThemeData theme;
  final ProfileStats stats;

  const _StatsGridCard({required this.theme, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '${stats.progressToNextLevel}%',
                  label: 'To Level ${stats.currentLevel + 1}',
                  valueColor: theme.colorScheme.secondary, // Orange
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '${stats.totalXp}',
                  label: 'Total EXP',
                  valueColor: theme.colorScheme.primary, // Blue
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '${stats.conceptsMastered}',
                  label: 'Concepts Mastered',
                  valueColor: const Color(0xFF4CAF50), // Green
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '${stats.currentLevel}',
                  label: 'Average Level',
                  valueColor: theme.colorScheme.tertiary, // Purple
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final ThemeData theme;

  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ADVANCED 2-TIER RADIAL SKILL TREE WIDGET
// =============================================================================

class _DynamicSkillTreeNetwork extends StatelessWidget {
  final ThemeData theme;
  final ProfileStats stats;

  const _DynamicSkillTreeNetwork({required this.theme, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 380, // Very tall to fit both orbits
            width: double.infinity,
            child: CustomPaint(
              painter: _AdvancedRadialPainter(theme: theme, stats: stats),
              child: Container(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hub, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Live Neo4j Graph Synchronization',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdvancedRadialPainter extends CustomPainter {
  final ThemeData theme;
  final ProfileStats stats;

  _AdvancedRadialPainter({required this.theme, required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Orbit Distances
    final double innerRadius = 85.0; // 4 Main Strands
    final double outerRadius = 150.0; // Neo4j Specific Topics

    // Styles
    final linePaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final outerLinePaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // --- 1. PREPARE THE 4 STRANDS (Inner Orbit) ---
    // Calculate levels based on overall gamification XP
    final strandData = [
      {
        'name': 'STEM',
        'level': stats.calculateBranchLevel(stats.stemXp),
        'color': const Color(0xFF2196F3),
        'angle': -math.pi * 0.75,
      }, // Top Left
      {
        'name': 'ABM',
        'level': stats.calculateBranchLevel(stats.abmXp),
        'color': const Color(0xFFFF9800),
        'angle': -math.pi * 0.25,
      }, // Top Right
      {
        'name': 'HUMSS',
        'level': stats.calculateBranchLevel(stats.humssXp),
        'color': const Color(0xFF9C27B0),
        'angle': math.pi * 0.75,
      }, // Bottom Left
      {
        'name': 'TVL',
        'level': stats.calculateBranchLevel(stats.tvlXp),
        'color': const Color(0xFF4CAF50),
        'angle': math.pi * 0.25,
      }, // Bottom Right
    ];

    // --- 2. PREPARE NEO4J TOPICS (Outer Orbit) ---
    final topics = stats.topSkills.entries.toList();
    final int topicCount = topics.length;

    final topicColors = [
      Colors.cyanAccent.shade400,
      Colors.pinkAccent.shade400,
      Colors.amberAccent.shade400,
      Colors.lightGreenAccent.shade400,
      Colors.deepPurpleAccent.shade100,
    ];

    // DRAW LINES FIRST (So they stay behind nodes)
    // Lines to inner strands
    for (var strand in strandData) {
      final angle = strand['angle'] as double;
      final dx = center.dx + innerRadius * math.cos(angle);
      final dy = center.dy + innerRadius * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), linePaint);
    }

    // Lines to outer topics
    for (int i = 0; i < topicCount; i++) {
      final angle = (2 * math.pi * i) / topicCount - (math.pi / 2); // Start top
      final dx = center.dx + outerRadius * math.cos(angle);
      final dy = center.dy + outerRadius * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), outerLinePaint);
    }

    // --- 3. DRAW OUTER ORBIT NODES (Neo4j Topics) ---
    for (int i = 0; i < topicCount; i++) {
      final topicName = topics[i].key;
      final topicLevel = topics[i].value;

      final angle = (2 * math.pi * i) / topicCount - (math.pi / 2);
      final dx = center.dx + outerRadius * math.cos(angle);
      final dy = center.dy + outerRadius * math.sin(angle);
      final nodeCenter = Offset(dx, dy);
      final nodeColor = topicColors[i % topicColors.length];

      // Dynamic Node Size based on Neo4j level
      final double nodeRadius = (18.0 + (topicLevel * 2.5)).clamp(18.0, 32.0);

      // Glow
      canvas.drawCircle(
        nodeCenter,
        nodeRadius + 3,
        Paint()
          ..color = nodeColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      // Solid Background
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()..color = theme.colorScheme.surface,
      );
      // Border
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()
          ..color = nodeColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );

      // Topic Level Text
      _drawText(
        canvas,
        'Lv.$topicLevel',
        nodeCenter,
        theme.colorScheme.onSurface,
        11,
        true,
      );
      // Topic Name Text (Below node)
      _drawText(
        canvas,
        topicName,
        Offset(dx, dy + nodeRadius + 12),
        theme.colorScheme.onSurface,
        10,
        false,
      );
    }

    // --- 4. DRAW INNER ORBIT NODES (4 Gamification Strands) ---
    for (var strand in strandData) {
      final name = strand['name'] as String;
      final level = strand['level'] as int;
      final color = strand['color'] as Color;
      final angle = strand['angle'] as double;

      final dx = center.dx + innerRadius * math.cos(angle);
      final dy = center.dy + innerRadius * math.sin(angle);
      final nodeCenter = Offset(dx, dy);
      final double nodeRadius = 26.0;

      // Solid Background
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()..color = theme.colorScheme.surface,
      );
      // Border
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()
          ..color = color
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke,
      );

      // Strand Level Text
      _drawText(canvas, 'Lv.$level', Offset(dx, dy - 4), color, 12, true);
      // Strand Name
      _drawText(
        canvas,
        name,
        Offset(dx, dy + 10),
        theme.colorScheme.onSurface,
        10,
        true,
      );
    }

    // --- 5. DRAW CORE NODE (Center) ---
    canvas.drawCircle(center, 40, Paint()..color = theme.colorScheme.surface);
    canvas.drawCircle(
      center,
      40,
      Paint()
        ..color = theme.colorScheme.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );

    final Rect coreRect = Rect.fromCircle(center: center, radius: 36);
    canvas.drawCircle(
      center,
      36,
      Paint()
        ..shader = LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(coreRect),
    );

    _drawText(
      canvas,
      'CORE',
      Offset(center.dx, center.dy - 6),
      Colors.white,
      11,
      true,
    );
    _drawText(
      canvas,
      'LV.${stats.currentLevel}',
      Offset(center.dx, center.dy + 8),
      Colors.white,
      16,
      true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
    bool isBold,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AdvancedRadialPainter oldDelegate) => true; // Always repaint on update to ensure animations/refreshes catch
}

// =============================================================================
// REMAINING BOILERPLATE (EDIT DIALOGS)
// =============================================================================

class _ProfileHeaderCard extends StatelessWidget {
  final ThemeData theme;
  final String fullName;
  final String educationLevel;
  final String location;
  final int streak;
  final VoidCallback onEditPressed;

  const _ProfileHeaderCard({
    required this.theme,
    required this.fullName,
    required this.educationLevel,
    required this.location,
    required this.streak,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.isNotEmpty
                          ? '$educationLevel • $location'
                          : educationLevel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        children: [
                          const TextSpan(text: 'Daily Streak '),
                          TextSpan(
                            text: '$streak',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Text(
                'Edit Profile →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePromoCard extends StatelessWidget {
  final ThemeData theme;
  final Color borderColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _ProfilePromoCard({
    required this.theme,
    required this.borderColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showEditNameDialog(String currentName) async {
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Edit Full Name',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter your new name',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'full_name': newName})
                          .eq('id', userId);
                      ref.invalidate(appUserProvider);
                      ref.invalidate(profileStatsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditCityDialog(String currentCity) async {
    final theme = Theme.of(context);
    final TextEditingController cityController = TextEditingController(
      text: currentCity,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Edit City',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: TextField(
            controller: cityController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter your city',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
              onPressed: () async {
                final newCity = cityController.text.trim();
                if (newCity != currentCity) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'city': newCity})
                          .eq('id', userId);
                      ref.invalidate(appUserProvider);
                      ref.invalidate(profileStatsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditCountryDialog(String currentCountry) async {
    final theme = Theme.of(context);
    final TextEditingController countryController = TextEditingController(
      text: currentCountry,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Edit Country',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: TextField(
            controller: countryController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter your country',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
              onPressed: () async {
                final newCountry = countryController.text.trim();
                if (newCountry != currentCountry) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client
                          .from('profiles')
                          .update({'country': newCountry})
                          .eq('id', userId);
                      ref.invalidate(appUserProvider);
                      ref.invalidate(profileStatsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Country updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                  }
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEducationLevelDialog(String currentLevel) async {
    final theme = Theme.of(context);
    final List<String> educationLevels = [
      'Elementary',
      'High School',
      'Senior High School',
      'Others',
    ];
    String? selectedLevel =
        currentLevel.isNotEmpty && educationLevels.contains(currentLevel)
        ? currentLevel
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Edit Education Level',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              content: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: theme.colorScheme.surface,
                    isExpanded: true,
                    hint: Text(
                      'Select your education level',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    value: selectedLevel,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.secondary,
                    ),
                    items: educationLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => selectedLevel = newValue);
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                  onPressed:
                      selectedLevel != null && selectedLevel != currentLevel
                      ? () async {
                          try {
                            final userId =
                                Supabase.instance.client.auth.currentUser?.id;
                            if (userId != null) {
                              await Supabase.instance.client
                                  .from('profiles')
                                  .update({'education_level': selectedLevel})
                                  .eq('id', userId);
                              ref.invalidate(appUserProvider);
                              ref.invalidate(profileStatsProvider);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Education updated successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                          }
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    final appUserState = ref.watch(appUserProvider);
    return appUserState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("Error")),
      data: (appUser) {
        if (appUser == null) return const Center(child: Text("Not logged in"));
        final profile = appUser.profile;
        final currentName = profile.fullName ?? 'Explorer';
        final currentCity = profile.city ?? '';
        final currentCountry = profile.country ?? '';
        final currentEducationLevel = profile.educationLevel ?? 'Not set';
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          'Full Name',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          currentName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditNameDialog(currentName),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          'City',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          currentCity.isNotEmpty ? currentCity : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditCityDialog(currentCity),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.public_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          'Country',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          currentCountry.isNotEmpty
                              ? currentCountry
                              : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditCountryDialog(currentCountry),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.school_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          'Education Level',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          currentEducationLevel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditEducationLevelDialog(
                          currentEducationLevel,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fade(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Settings'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(theme),
                const Center(child: Text("Settings")),
                const Center(child: Text("About")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
