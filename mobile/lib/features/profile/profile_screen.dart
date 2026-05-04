import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

import '../../core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_controller.dart';
import 'pathfinder_blueprint_sheet.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/pathfinder_service.dart';
import 'services/profile_service.dart';
import 'screens/change_password_screen.dart';
import '../auth/presentation/widgets/auth_gate.dart';

// =========================================================================
// DATA STRUCTURES & LOGIC
// =========================================================================

class SkillNode {
  final String id;
  final String title;
  final String description;
  final String strand;
  final int xp;
  final int level;
  final Color color;
  final double angle;
  final double radialDistance;
  final double radius;
  final IconData? icon;

  SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.strand,
    required this.xp,
    required this.level,
    required this.color,
    required this.angle,
    required this.radialDistance,
    this.radius = 35.0,
    this.icon,
  });
}

class ProfileStats {
  final int totalXp;
  final int currentLevel;
  final int conceptsMastered;
  final int stemXp;
  final int humssXp;
  final int abmXp;
  final int tvlXp;
  final List<String> topSkills;

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

  int get progressToNextLevel => ((totalXp % 500) / 500 * 100).toInt();
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
      topSkills: [],
    );
  }

  final profileRes = await client
      .from('profiles')
      .select('total_xp, current_level')
      .eq('id', userId)
      .maybeSingle();
  final treeRes = await client
      .from('kaalaman_skill_tree')
      .select()
      .eq('user_id', userId)
      .maybeSingle();
  final scansRes = await client
      .from('scans')
      .select('id')
      .eq('user_id', userId);
  final neo4jData = await PathfinderService.getSkillWeb();

  List<String> parsedTopSkills = [];
  if (neo4jData != null && neo4jData['top_skills'] != null) {
    parsedTopSkills = List<String>.from(neo4jData['top_skills']);
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

// 🚀 CLUSTERED LAYOUT ALGORITHM
List<SkillNode> generateSkillNodes(
  ProfileStats stats,
  String userName,
  ThemeData theme,
) {
  final nodes = <SkillNode>[];

  // 1. Center Root Node (The User)
  nodes.add(
    SkillNode(
      id: 'root',
      title: userName.toUpperCase(),
      description: 'Your central learning core.',
      strand: 'root',
      xp: stats.totalXp, // 🚀 FIX: Actual Total XP
      level: stats.currentLevel, // 🚀 FIX: Actual Global Level
      color: theme.colorScheme.primary,
      angle: 0,
      radialDistance: 0,
      radius: 50.0,
    ),
  );

  // 2. Base Strands (Angles push them to 4 corners)
  final strandData = {
    'stem': {
      'xp': stats.stemXp,
      'angle': -math.pi * 0.75,
      'color': Colors.green[600]!,
    },
    'abm': {
      'xp': stats.abmXp,
      'angle': -math.pi * 0.25,
      'color': Colors.blue[600]!,
    },
    'tvl': {
      'xp': stats.tvlXp,
      'angle': math.pi * 0.25,
      'color': Colors.red[500]!,
    },
    'humss': {
      'xp': stats.humssXp,
      'angle': math.pi * 0.75,
      'color': Colors.orange[600]!,
    },
  };

  strandData.forEach((id, data) {
    final strandXp = data['xp'] as int;
    nodes.add(
      SkillNode(
        id: id,
        title: id.toUpperCase(),
        description: 'Core SHS Pathway',
        strand: 'root',
        xp: strandXp,
        level: (strandXp ~/ 500) + 1, // 0 XP = Lv 1, 500 XP = Lv 2
        color: data['color'] as Color,
        angle: data['angle'] as double,
        radialDistance: 130.0,
        radius: 38.0,
      ),
    );
  });

  // 3. Clustered Outer Skills
  final topicColors = [
    Colors.cyan.shade400,
    Colors.pink.shade400,
    Colors.amber.shade400,
    Colors.deepPurple.shade300,
  ];
  final strandSkillCounts = <String, int>{};

  for (int i = 0; i < stats.topSkills.length; i++) {
    final skillString = stats.topSkills[i];
    final regex = RegExp(r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$');
    final match = regex.firstMatch(skillString);

    String skillName = skillString;
    String domainName = 'Discipline';
    String strandName = 'stem';
    int parsedLevel = 1;

    if (match != null) {
      skillName = match.group(1)?.trim() ?? skillName;
      domainName = match.group(2)?.trim() ?? domainName;
      strandName = match.group(3)?.trim().toLowerCase() ?? 'stem';
      parsedLevel = int.tryParse(match.group(4) ?? '1') ?? 1;
    }

    if (!strandData.containsKey(strandName)) strandName = 'stem';

    final parentData = strandData[strandName]!;
    final baseAngle = parentData['angle'] as double;
    final parentColor = parentData['color'] as Color;

    final count = strandSkillCounts[strandName] ?? 0;
    strandSkillCounts[strandName] = count + 1;

    // Spreads skills out AROUND their parent strand so lines never cross the center
    final offset = (count == 0)
        ? 0.0
        : (count % 2 == 0 ? 1 : -1) * ((count + 1) ~/ 2) * 0.35;
    final finalAngle = baseAngle + offset;

    nodes.add(
      SkillNode(
        id: 'skill_$i',
        title: skillName,
        description: domainName,
        strand: strandName,
        xp: parsedLevel * 50, // 🚀 FIX: Lv 1 = 50 XP, Lv 2 = 100 XP
        level: parsedLevel,
        color: count == 0 ? parentColor : topicColors[i % topicColors.length],
        angle: finalAngle,
        radialDistance: 270.0 + (count > 2 ? 40 : 0),
        radius: (30.0 + (parsedLevel * 2.0)).clamp(30.0, 45.0),
      ),
    );
  }

  return nodes;
}

// 🚀 BOTTOM SHEET INTERACTIVE UI
void _showNodeDetailsBottomSheet(BuildContext context, SkillNode node) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: node.color.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: node.color.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: node.color.withValues(alpha: 0.15),
                radius: 30,
                child: Icon(
                  node.id == 'root' ? Icons.person : Icons.hub,
                  color: node.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                node.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                node.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatPill('LEVEL', '${node.level}', node.color),
                  _buildStatPill(
                    'TOTAL XP',
                    '${node.xp}',
                    node.color,
                  ), // Now displays for ALL nodes!
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStatPill(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}

// =========================================================================
// MAIN SCREENS
// =========================================================================

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile & Skill Tree'),
        foregroundColor: theme.colorScheme.primary,
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
          String location = profile.city ?? '';
          if (location.isNotEmpty && profile.country?.isNotEmpty == true) {
            location += ', ${profile.country}';
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
                  profilePictureUrl: profile.profilePictureUrl,
                  bio: profile.bio,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTabs extends ConsumerStatefulWidget {
  final ThemeData theme;
  final String currentName;
  final String currentEducationLevel;
  final String location;
  final int streak;
  final String? profilePictureUrl;
  final String? bio;

  const _ProfileTabs({
    required this.theme,
    required this.currentName,
    required this.currentEducationLevel,
    required this.location,
    required this.streak,
    this.profilePictureUrl,
    this.bio,
  });

  @override
  ConsumerState<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends ConsumerState<_ProfileTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
              color: widget.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: widget.theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: widget.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: widget.theme.colorScheme.onPrimary,
              unselectedLabelColor: widget.theme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
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
            physics:
                const NeverScrollableScrollPhysics(), // 🚀 Swiping Disabled Here
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
            profilePictureUrl: widget.profilePictureUrl,
            onEditPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ).then((_) => ref.invalidate(appUserProvider));
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
              'Inner nodes track your gamification strands. Outer nodes are dynamic topics you mastered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),
          ),
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
          statsAsync.when(
            loading: () => const SizedBox(height: 350),
            error: (e, s) => const SizedBox(),
            data: (stats) {
              final nodes = generateSkillNodes(
                stats,
                widget.currentName,
                theme,
              );
              return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _DynamicSkillTreeNetwork(
                      theme: theme,
                      nodes: nodes,
                      userName: widget.currentName,
                    ),
                  )
                  .animate()
                  .fade(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.1);
            },
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
                      onPressed: () {
                        final currentStats = statsAsync.value;
                        showPathfinderBlueprintSheet(
                          context,
                          stemXp: currentStats?.stemXp ?? 0,
                          humssXp: currentStats?.humssXp ?? 0,
                          abmXp: currentStats?.abmXp ?? 0,
                          tvlXp: currentStats?.tvlXp ?? 0,
                          onNavigateToScan: () =>
                              MainNavScope.maybeOf(context)?.goToTab(1),
                        );
                      },
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    final isEmailUser = ref.watch(isEmailPasswordUserProvider);
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
                    activeThumbColor: theme.colorScheme.primary,
                    onChanged: (bool value) => appThemeNotifier.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  );
                },
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
              if (isEmailUser)
                ListTile(
                  leading: Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Change Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
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
                  final nav = Navigator.of(context, rootNavigator: true);
                  await Supabase.instance.client.auth.signOut();
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildAboutTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // App Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(Icons.school, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Tuklascope is a modern learning companion that helps you discover, track, and engage with educational content. Built with love and purpose to make learning accessible for everyone.',
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

        const SizedBox(height: 20),

        // Developers
        Text(
          'Developed by:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'John Michael A. Nave',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'James Andrew S. Ologuin',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'John Peter D. Pestaño',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'Jordan A. Cabandon',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ListTile(
                leading: Icon(Icons.code, color: theme.colorScheme.secondary),
                title: Text(
                  'John Zachary N. Gillana',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// =============================================================================
// TREE VISUALIZATION WIDGETS
// =============================================================================

// =============================================================================
// TREE VISUALIZATION WIDGETS
// =============================================================================

class _DynamicSkillTreeNetwork extends StatelessWidget {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final String userName;

  const _DynamicSkillTreeNetwork({
    required this.theme,
    required this.nodes,
    required this.userName,
  });

  void _handleTap(BuildContext context, Offset localPosition) {
    const center = Offset(400, 400);
    for (var node in nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        _showNodeDetailsBottomSheet(context, node);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 800,
                      height: 800,
                      child: GestureDetector(
                        onTapUp: (details) =>
                            _handleTap(context, details.localPosition),
                        child: CustomPaint(
                          painter: _OrganicTreePainter(
                            theme: theme,
                            nodes: nodes,
                            scale: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface.withValues(
                        alpha: 0.8,
                      ),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).push(
                          // 🚀 FIX: rootNavigator: true hides the bottom tabs!
                          MaterialPageRoute(
                            builder: (context) => _FullScreenSkillTree(
                              theme: theme,
                              nodes: nodes,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              // 🚀 FIX: rootNavigator: true here as well
              MaterialPageRoute(
                builder: (context) =>
                    _FullScreenSkillTree(theme: theme, nodes: nodes),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.zoom_out_map,
                    size: 16,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to expand & explore interactively',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenSkillTree extends StatefulWidget {
  final ThemeData theme;
  final List<SkillNode> nodes;

  const _FullScreenSkillTree({required this.theme, required this.nodes});

  @override
  State<_FullScreenSkillTree> createState() => _FullScreenSkillTreeState();
}

class _FullScreenSkillTreeState extends State<_FullScreenSkillTree> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // 🚀 FIX: The canvas is 2000x2000, so its center is 1000x1000.
    // This perfectly centers the camera on the user's name when they open full screen!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final offsetX = 1000.0 - (screenSize.width / 2);
      final offsetY = 1000.0 - (screenSize.height / 2);
      // 🚀 FIX: Use modern Matrix4.translationValues (x, y, z)
      _transformationController.value = Matrix4.translationValues(
        -offsetX,
        -offsetY,
        0.0,
      );
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    const center = Offset(1000, 1000);
    for (var node in widget.nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        _showNodeDetailsBottomSheet(context, node);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: widget.theme.colorScheme.primary,
        title: const Text('Interactive Skill Tree'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pinch,
                    size: 16,
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinch to zoom • Drag to pan',
                    style: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                transformationController:
                    _transformationController, // 🚀 Uses the centering controller
                minScale: 0.2,
                maxScale: 3.5,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(1000),
                child: SizedBox(
                  width: 2000,
                  height: 2000,
                  child: GestureDetector(
                    onTapUp: (details) =>
                        _handleTap(context, details.localPosition),
                    child: CustomPaint(
                      painter: _OrganicTreePainter(
                        theme: widget.theme,
                        nodes: widget.nodes,
                        scale: 1.0,
                        isFullScreen: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganicTreePainter extends CustomPainter {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final double scale;
  final bool isFullScreen;

  _OrganicTreePainter({
    required this.theme,
    required this.nodes,
    required this.scale,
    this.isFullScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final center = isFullScreen
        ? const Offset(1000, 1000)
        : const Offset(400, 400);

    Offset getOffset(SkillNode node) =>
        center +
        Offset(
          node.radialDistance * math.cos(node.angle),
          node.radialDistance * math.sin(node.angle),
        );

    void drawOrganicBranch(SkillNode n1, SkillNode n2, Color color) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);

      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      final cpX = midPoint.dx - math.sin(angle) * 30;
      final cpY = midPoint.dy + math.cos(angle) * 30;

      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (n1.id == 'root' ? 4.0 : 2.0),
      );
    }

    final root = nodes.firstWhere((n) => n.id == 'root');
    for (var node in nodes) {
      if (node.id == 'root') continue;
      if (node.strand == 'root') {
        drawOrganicBranch(root, node, node.color);
      } else {
        final parentNode = nodes.firstWhere(
          (n) => n.id == node.strand,
          orElse: () => root,
        );
        drawOrganicBranch(parentNode, node, node.color);
      }
    }

    for (var node in nodes) {
      final pCenter = getOffset(node);

      if (node.id == 'root') {
        final Rect coreRect = Rect.fromCircle(
          center: pCenter,
          radius: node.radius,
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..shader = LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ).createShader(coreRect),
        );
      } else {
        canvas.drawCircle(
          pCenter,
          node.radius + 4,
          Paint()
            ..color = node.color.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()..color = theme.colorScheme.surface,
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..color = node.color
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke,
        );
      }

      final text = node.id == 'root' ? node.title : node.title.split(' ')[0];
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: node.id == 'root'
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontSize: node.id == 'root' ? 16 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          pCenter.dx - (textPainter.width / 2),
          pCenter.dy - (textPainter.height / 2),
        ),
      );

      if (node.id != 'root') {
        final levelPainter = TextPainter(
          text: TextSpan(
            text: 'Lv.${node.level}',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        levelPainter.paint(
          canvas,
          pCenter + Offset(-levelPainter.width / 2, node.radius + 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicTreePainter oldDelegate) => true;
}

// =============================================================================
// EDIT PROFILE SCREEN (Unchanged)
// =============================================================================

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
                  valueColor: theme.colorScheme.secondary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '${stats.totalXp}',
                  label: 'Total EXP',
                  valueColor: theme.colorScheme.primary,
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
                  valueColor: const Color(0xFF4CAF50),
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '${stats.currentLevel}',
                  label: 'Average Level',
                  valueColor: theme.colorScheme.tertiary,
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

class _ProfileHeaderCard extends StatelessWidget {
  final ThemeData theme;
  final String fullName, educationLevel, location;
  final int streak;
  final String? profilePictureUrl;
  final VoidCallback onEditPressed;
  const _ProfileHeaderCard({
    required this.theme,
    required this.fullName,
    required this.educationLevel,
    required this.location,
    required this.streak,
    this.profilePictureUrl,
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
                  backgroundImage: profilePictureUrl?.isNotEmpty == true
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl?.isEmpty ?? true
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        )
                      : null,
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
  final Color borderColor, buttonColor;
  final String title, description, buttonLabel;
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
        border: Border.all(color: borderColor),
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

  Future<void> _showEditDialog(
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(title, style: TextStyle(color: theme.colorScheme.primary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.secondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
              if (controller.text.trim().isNotEmpty &&
                  controller.text.trim() != initialValue) {
                final nav = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await onSave(controller.text.trim());
                  ref.invalidate(appUserProvider);
                  ref.invalidate(profileStatsProvider);
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              } else {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    final theme = Theme.of(context);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context, rootNavigator: true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 20),
                  const Text('Uploading...'),
                ],
              ),
            ),
          ),
        );
        await ref
            .read(profileServiceProvider)
            .uploadProfilePicture(pickedFile.path);
        nav.pop();
        ref.invalidate(appUserProvider);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Widget _buildProfileTab(ThemeData theme) {
    final appUserState = ref.watch(appUserProvider);
    return appUserState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("Error")),
      data: (appUser) {
        if (appUser == null) return const Center(child: Text("Not logged in"));
        final profile = appUser.profile;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 3,
                      ),
                      color: theme.colorScheme.surface,
                    ),
                    child: profile.profilePictureUrl?.isNotEmpty == true
                        ? ClipOval(
                            child: Image.network(
                              profile.profilePictureUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Change profile picture',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
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
                    title: const Text('Full Name'),
                    subtitle: Text(profile.fullName ?? 'Explorer'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Name',
                      profile.fullName ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'full_name': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: const Text('City'),
                    subtitle: Text(profile.city ?? 'Not set'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit City',
                      profile.city ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'city': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: const Text('Country'),
                    subtitle: Text(profile.country ?? 'Not set'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Country',
                      profile.country ?? '',
                      (v) => Supabase.instance.client
                          .from('profiles')
                          .update({'country': v})
                          .eq('id', profile.id),
                    ),
                  ),
                  ListTile(
                    title: const Text('Bio'),
                    subtitle: Text(profile.bio ?? 'Not set'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      'Edit Bio',
                      profile.bio ?? '',
                      (v) => ref.read(profileServiceProvider).updateBio(v),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
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
      body: _buildProfileTab(theme), // Just show the edit form directly
    );
  }
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return GradientScaffold(
  //     appBar: AppBar(
  //       title: const Text('Edit Profile'),
  //       foregroundColor: theme.colorScheme.primary,
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //     ),
  //     body: Column(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Container(
  //             height: 50,
  //             decoration: BoxDecoration(
  //               color: theme.colorScheme.surface,
  //               borderRadius: BorderRadius.circular(25),
  //             ),
  //             child: TabBar(
  //               controller: _tabController,
  //               indicator: BoxDecoration(
  //                 color: theme.colorScheme.primary,
  //                 borderRadius: BorderRadius.circular(25),
  //               ),
  //               labelColor: theme.colorScheme.onPrimary,
  //               tabs: const [
  //                 Tab(text: 'Profile'),
  //                 Tab(text: 'Settings'),
  //                 Tab(text: 'About'),
  //               ],
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: TabBarView(
  //             controller: _tabController,
  //             physics: const NeverScrollableScrollPhysics(),
  //             children: [
  //               _buildProfileTab(theme),
  //               const Center(child: Text("Settings")),
  //               const Center(child: Text("About")),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
