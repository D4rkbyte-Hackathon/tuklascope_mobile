import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/navigation/main_nav_scope.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_controller.dart';
import '../../home/providers/home_provider.dart';
import '../../auth/presentation/widgets/auth_gate.dart';
import '../pathfinder_blueprint_sheet.dart'; 
import '../screens/change_password_screen.dart'; 

import '../providers/profile_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/stats_grid_card.dart';
import '../widgets/skill_tree_visualizer.dart';
import '../widgets/profile_promo_card.dart';
import 'edit_profile_screen.dart';
import '../widgets/about_tab.dart'; // Add this line!

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appUserState = ref.watch(appUserProvider);

    return GradientScaffold(
      appBar: AppBar(
        centerTitle: true, // Centers the title horizontally
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 30, 
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Profile & ',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              TextSpan(
                text: 'Skill Tree',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2), // Smooth drop-in animation
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
            style: GoogleFonts.inter(color: theme.colorScheme.error),
          ),
        ),
        data: (appUser) {
          if (appUser == null) {
            return Center(
              child: Text(
                'Please log in.',
                style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
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
                child: ProfileTabsSection(
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

class ProfileTabsSection extends ConsumerStatefulWidget {
  final ThemeData theme;
  final String currentName;
  final String currentEducationLevel;
  final String location;
  final int streak;
  final String? profilePictureUrl;
  final String? bio;

  const ProfileTabsSection({
    super.key,
    required this.theme,
    required this.currentName,
    required this.currentEducationLevel,
    required this.location,
    required this.streak,
    this.profilePictureUrl,
    this.bio,
  });

  @override
  ConsumerState<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends ConsumerState<ProfileTabsSection>
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
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Settings'),
                Tab(text: 'About'),
              ],
            ),
          )
          // --- Tab bar drop-in animation ---
          .animate().fade(duration: 400.ms).slideY(begin: -0.2), 
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), 
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
          MediaQuery.paddingOf(context).bottom + 20,
        ),
        children: [
          ProfileHeaderCard(
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
          )
          .animate()
          .scale(duration: 500.ms, curve: Curves.easeOutBack) // Bouncy pop in!
          .shimmer(duration: 2.seconds, delay: 600.ms, color: Colors.white.withValues(alpha: 0.2)), // Shimmer across the card

          Padding(
            padding: const EdgeInsets.only(top: 28, bottom: 12),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.montserrat(
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
                    style: GoogleFonts.orbitron(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 500.ms, delay: 100.ms).slideX(begin: -0.1),

          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Text(
              'Inner nodes track your gamification strands. Outer nodes are dynamic topics you mastered.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),
          ).animate().fade(duration: 500.ms, delay: 150.ms),

          statsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            error: (e, s) => Center(
              child: Text('Error loading stats', style: GoogleFonts.inter()),
            ),
            data: (stats) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: StatsGridCard(theme: theme, stats: stats),
            )
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 400.ms),
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
                child: DynamicSkillTreeNetwork(
                  theme: theme,
                  nodes: nodes,
                  userName: widget.currentName,
                ),
              )
              .animate()
              .fade(duration: 600.ms, delay: 300.ms)
              .scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack);
            },
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProfilePromoCard(
              theme: theme,
              borderColor: theme.colorScheme.secondary,
              title: 'Open Your Blueprint',
              description: 'See how your skills map to real-world careers.',
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
            .fade(duration: 600.ms, delay: 400.ms)
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
                  final isDarkMode = currentMode == ThemeMode.dark ||
                      (currentMode == ThemeMode.system && isSystemDark);
                  return SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: GoogleFonts.inter(
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
            style: GoogleFonts.montserrat(
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
                    style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                trailing: Icon(Icons.logout, color: theme.colorScheme.error),
                onTap: () async {
                  final nav = Navigator.of(context, rootNavigator: true);
                  await Supabase.instance.client.auth.signOut();
                  ref.invalidate(homeStatsProvider);
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildAboutTab(ThemeData theme) {
    return AboutTab(theme: theme);
  }
}