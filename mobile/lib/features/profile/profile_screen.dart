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
// STATE MANAGEMENT: PROFILE STATS PROVIDER
// =========================================================================

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

  int get progressToNextLevel {
    final int xpIntoCurrentLevel = totalXp % 500;
    return ((xpIntoCurrentLevel / 500) * 100).toInt();
  }

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

// =========================================================================
// MAIN SCREEN
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
                const NeverScrollableScrollPhysics(), // 🚀 FIX: Disables swiping between tabs
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ).then((_) {
                ref.invalidate(appUserProvider);
              });
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
              'Inner nodes track your overall gamification strands. Outer nodes are specific topics mastered through discovery.',
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
            loading: () => const SizedBox(height: 250),
            error: (e, s) => const SizedBox(),
            data: (stats) =>
                Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _DynamicSkillTreeNetwork(
                        theme: theme,
                        stats: stats,
                        userName:
                            widget.currentName, // 🚀 NEW: Passing user name
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
          _ProfilePromoCard(
            theme: theme,
            borderColor: theme.colorScheme.primary.withValues(alpha: 0.35),
            title: 'Expand Your Network',
            description:
                'Scan new objects to grow the branches of your skill tree!',
            buttonLabel: 'Start Discovery →',
            buttonColor: theme.colorScheme.secondary,
            onPressed: () => MainNavScope.maybeOf(context)?.goToTab(1),
          ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),
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
                activeThumbColor: theme.colorScheme.secondary,
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
              if (isEmailUser)
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Update your security',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                ListTile(
                  leading: Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  title: Text(
                    'Change Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  subtitle: Text(
                    'Not available for OAuth accounts (Google/Facebook)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  enabled: false,
                ),
              if (isEmailUser)
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
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
  final String fullName;
  final String educationLevel;
  final String location;
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

// =============================================================================
// DYNAMIC SKILL TREE NETWORK WIDGET (INLINE PREVIEW)
// =============================================================================

class _DynamicSkillTreeNetwork extends StatelessWidget {
  final ThemeData theme;
  final ProfileStats stats;
  final String userName; // 🚀 NEW

  const _DynamicSkillTreeNetwork({
    required this.theme,
    required this.stats,
    required this.userName,
  });

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
                  child: CustomPaint(
                    size: const Size(double.infinity, 350),
                    painter: _AdvancedInteractiveRadialPainter(
                      theme: theme,
                      stats: stats,
                      userName: userName,
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _FullScreenSkillTree(
                            theme: theme,
                            stats: stats,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _FullScreenSkillTree(
                    theme: theme,
                    stats: stats,
                    userName: userName,
                  ),
                ),
              );
            },
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

class _AdvancedInteractiveRadialPainter extends CustomPainter {
  final ThemeData theme;
  final ProfileStats stats;
  final String userName; // 🚀 NEW

  _AdvancedInteractiveRadialPainter({
    required this.theme,
    required this.stats,
    required this.userName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    const double innerRadius = 90.0;
    const double outerRadius = 175.0;

    final innerLinePaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final outerLinePaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final strandData = [
      {
        'name': 'STEM',
        'level': stats.calculateBranchLevel(stats.stemXp),
        'color': const Color(0xFF2196F3),
        'angle': -math.pi * 0.75,
      },
      {
        'name': 'ABM',
        'level': stats.calculateBranchLevel(stats.abmXp),
        'color': const Color(0xFFFF9800),
        'angle': -math.pi * 0.25,
      },
      {
        'name': 'HUMSS',
        'level': stats.calculateBranchLevel(stats.humssXp),
        'color': const Color(0xFF9C27B0),
        'angle': math.pi * 0.75,
      },
      {
        'name': 'TVL',
        'level': stats.calculateBranchLevel(stats.tvlXp),
        'color': const Color(0xFF4CAF50),
        'angle': math.pi * 0.25,
      },
    ];

    final topics = stats.topSkills;
    final int topicCount = topics.length;

    final topicColors = [
      Colors.cyan.shade600,
      Colors.pink.shade500,
      Colors.amber.shade600,
      Colors.lightGreen.shade600,
      Colors.deepPurple.shade400,
    ];

    for (var strand in strandData) {
      final angle = strand['angle'] as double;
      final dx = center.dx + innerRadius * math.cos(angle);
      final dy = center.dy + innerRadius * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), innerLinePaint);
    }

    for (int i = 0; i < topicCount; i++) {
      final skillString = topics[i];
      // 🚀 FIX: Parse the new [Strand] format from the backend!
      final regex = RegExp(r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$');
      final match = regex.firstMatch(skillString);

      String strandName = 'STEM';

      if (match != null) {
        strandName = match.group(3)?.trim().toUpperCase() ?? 'STEM';
      }

      final angle = (2 * math.pi * i) / topicCount - (math.pi / 2);
      final dx = center.dx + outerRadius * math.cos(angle);
      final dy = center.dy + outerRadius * math.sin(angle);
      final topicPos = Offset(dx, dy);

      // 🚀 FIX: Draw a true connected branch directly to its actual parent strand!
      Offset parentStrandPos = center;
      for (var strand in strandData) {
        if (strand['name'] == strandName) {
          final sAngle = strand['angle'] as double;
          parentStrandPos =
              center +
              Offset(
                innerRadius * math.cos(sAngle),
                innerRadius * math.sin(sAngle),
              );
          break;
        }
      }
      canvas.drawLine(parentStrandPos, topicPos, outerLinePaint);
    }

    for (int i = 0; i < topicCount; i++) {
      final skillString = topics[i];
      final regex = RegExp(r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$');
      final match = regex.firstMatch(skillString);

      String topicName = skillString;
      int topicLevel = 1;

      if (match != null) {
        topicName = match.group(1)?.trim() ?? topicName;
        topicLevel = int.tryParse(match.group(4) ?? '1') ?? 1;
      }

      final angle = (2 * math.pi * i) / topicCount - (math.pi / 2);
      final dx = center.dx + outerRadius * math.cos(angle);
      final dy = center.dy + outerRadius * math.sin(angle);
      final nodeCenter = Offset(dx, dy);
      final nodeColor = topicColors[i % topicColors.length];

      final double nodeRadius = (35.0 + (topicLevel * 2.0)).clamp(35.0, 48.0);

      canvas.drawCircle(
        nodeCenter,
        nodeRadius + 3,
        Paint()
          ..color = nodeColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()..color = theme.colorScheme.surface,
      );
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()
          ..color = nodeColor
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke,
      );

      final String displayName = topicName.length > 12
          ? '${topicName.substring(0, 10)}..'
          : topicName;
      _drawMultiLineText(
        canvas,
        'Lv.$topicLevel\n$displayName',
        nodeCenter,
        theme.colorScheme.onSurface,
        10,
        true,
      );
    }

    for (var strand in strandData) {
      final name = strand['name'] as String;
      final level = strand['level'] as int;
      final color = strand['color'] as Color;
      final angle = strand['angle'] as double;

      final dx = center.dx + innerRadius * math.cos(angle);
      final dy = center.dy + innerRadius * math.sin(angle);
      final nodeCenter = Offset(dx, dy);
      const double nodeRadius = 32.0;

      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()..color = theme.colorScheme.surface,
      );
      canvas.drawCircle(
        nodeCenter,
        nodeRadius,
        Paint()
          ..color = color
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke,
      );

      _drawMultiLineText(
        canvas,
        'Lv.$level\n$name',
        nodeCenter,
        theme.colorScheme.onSurface,
        10,
        true,
      );
    }

    canvas.drawCircle(center, 45, Paint()..color = theme.colorScheme.surface);
    canvas.drawCircle(
      center,
      45,
      Paint()
        ..color = theme.colorScheme.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );

    final Rect coreRect = Rect.fromCircle(center: center, radius: 40);
    canvas.drawCircle(
      center,
      40,
      Paint()
        ..shader = LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(coreRect),
    );

    _drawMultiLineText(
      canvas,
      '${userName.toUpperCase()}\nLV.${stats.currentLevel}', // 🚀 Shows User Name
      center,
      Colors.white,
      12,
      true,
    );
  }

  void _drawMultiLineText(
    Canvas canvas,
    String text,
    Offset centerOffset,
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
        height: 1.2,
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
        centerOffset.dx - textPainter.width / 2,
        centerOffset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AdvancedInteractiveRadialPainter oldDelegate) =>
      true;
}

// =============================================================================
// FULL SCREEN INTERACTIVE SKILL TREE
// =============================================================================

class _FullScreenSkillTree extends StatelessWidget {
  final ThemeData theme;
  final ProfileStats stats;
  final String userName;

  const _FullScreenSkillTree({
    required this.theme,
    required this.stats,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.primary,
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinch to zoom • Drag to pan',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: _AdvancedInteractiveRadialPainter(
                      theme: theme,
                      stats: stats,
                      userName: userName,
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

// =============================================================================
// EDIT PROFILE SCREEN
// =============================================================================

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
      builder: (dialogContext) {
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
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  final nav = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
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

                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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
      builder: (dialogContext) {
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
                final newCity = cityController.text.trim();
                if (newCity != currentCity) {
                  final nav = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
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

                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('City updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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
      builder: (dialogContext) {
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
                final newCountry = countryController.text.trim();
                if (newCountry != currentCountry) {
                  final nav = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
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

                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Country updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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
        );
      },
    );
  }

  Future<void> _showEditEducationLevelDialog(String currentLevel) async {
    final theme = Theme.of(context);
    const List<String> educationLevels = [
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
      builder: (dialogContext) {
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
                  onPressed:
                      selectedLevel != null && selectedLevel != currentLevel
                      ? () async {
                          final nav = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
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

                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Education updated successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            nav.pop();
                            messenger.showSnackBar(
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

  Future<void> _showEditBioDialog(String currentBio) async {
    final theme = Theme.of(context);
    final TextEditingController bioController = TextEditingController(
      text: currentBio,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Edit Bio',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: TextField(
            controller: bioController,
            maxLines: 4,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Tell us about yourself',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
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
                final nav = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref
                      .read(profileServiceProvider)
                      .updateBio(bioController.text.trim());
                  ref.invalidate(appUserProvider);

                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Bio updated successfully!'),
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
          builder: (ctx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 20),
                    const Text('Uploading profile picture...'),
                  ],
                ),
              ),
            );
          },
        );

        await ref
            .read(profileServiceProvider)
            .uploadProfilePicture(pickedFile.path);

        nav.pop(); // Close dialog

        ref.invalidate(appUserProvider);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
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
          content: Text('Error uploading picture: $e'),
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
        if (appUser == null) {
          return const Center(child: Text("Not logged in"));
        }
        final profile = appUser.profile;
        final currentName = profile.fullName ?? 'Explorer';
        final currentCity = profile.city ?? '';
        final currentCountry = profile.country ?? '';
        final currentEducationLevel = profile.educationLevel ?? 'Not set';
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
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: theme.colorScheme.primary,
                                  ),
                                );
                              },
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
                  if (profile.profilePictureUrl?.isNotEmpty == true)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.network(
                                profile.profilePictureUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'See profile picture',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (profile.profilePictureUrl?.isNotEmpty == true)
                    const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Choose profile picture',
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
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.description_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          'Bio',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          profile.bio?.isNotEmpty == true
                              ? profile.bio!
                              : 'Not set',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        onTap: () => _showEditBioDialog(profile.bio ?? ''),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
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
              physics: const NeverScrollableScrollPhysics(),
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
