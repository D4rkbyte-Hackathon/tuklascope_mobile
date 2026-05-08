//explore leaderboard tab
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'discoverer_row_card.dart';
import 'leaderboard_podium.dart'; 
import 'discoverer_profile_sheet.dart'; 

enum LocationScope { global, country, city }

class ExploreLeaderboardTab extends StatefulWidget {
  const ExploreLeaderboardTab({super.key});

  @override
  State<ExploreLeaderboardTab> createState() => _ExploreLeaderboardTabState();
}

class _ExploreLeaderboardTabState extends State<ExploreLeaderboardTab> with SingleTickerProviderStateMixin {
  late TabController _filterTabController;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoadingLeaderboard = true;
  
  int _currentFilterIndex = 0; 
  LocationScope _currentLocationScope = LocationScope.global; 
  
  // Track the current user's profile data
  String? _myCountry;
  String? _myCity;
  String? _myEducationLevel;
  int _myIndex = -1;

  // Smart FAB Visibility States
  bool _showGoToTop = false;
  bool _showGoToMe = false;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 2, vsync: this);
    _fetchLeaderboard();

    _filterTabController.addListener(() {
      if (_filterTabController.index != _currentFilterIndex) {
        _currentFilterIndex = _filterTabController.index;
        _fetchLeaderboard();
      }
    });

    // Attach the smart scroll listener
    _scrollController.addListener(_evaluateFabVisibility);
  }

  // --- SMART FAB LOGIC ---
  void _evaluateFabVisibility() {
    if (!_scrollController.hasClients) return;
    
    final offset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    // Go To Top Logic
    bool newShowGoToTop = offset > 250;

    // Go To Me Logic (Calculate if the user's row is currently rendered on screen)
    bool newShowGoToMe = false;
    if (_myIndex != -1) {
      double myEstimatedOffset = 0.0;
      if (_myIndex < 3) {
        myEstimatedOffset = 0.0; // Podium area
      } else {
        myEstimatedOffset = 220.0 + ((_myIndex - 3) * 80.0); // Podium height + (Index * Row height)
      }
      
      // If the estimated offset is outside the current viewport bounds
      bool isAboveViewport = myEstimatedOffset < (offset - 80); 
      bool isBelowViewport = myEstimatedOffset > (offset + viewportHeight - 100);
      
      newShowGoToMe = isAboveViewport || isBelowViewport;
    }

    // Only trigger setState if something actually changed to avoid lag
    if (_showGoToTop != newShowGoToTop || _showGoToMe != newShowGoToMe) {
      setState(() {
        _showGoToTop = newShowGoToTop;
        _showGoToMe = newShowGoToMe;
      });
    }
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoadingLeaderboard = true);
    
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      var query = Supabase.instance.client
          .from('profiles')
          .select('id, full_name, total_xp, education_level, profile_picture_url, bio, country, city, current_streak, current_level');

      if (currentUser != null) {
        final myProfile = await Supabase.instance.client
            .from('profiles')
            .select('education_level, country, city')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (myProfile != null) {
          _myCountry = myProfile['country'];
          _myCity = myProfile['city'];
          _myEducationLevel = myProfile['education_level'];

          if (_currentFilterIndex == 0 && _myEducationLevel != null) {
            query = query.eq('education_level', _myEducationLevel!);
          } else if (_currentFilterIndex == 1) {
            if (_currentLocationScope == LocationScope.country && _myCountry != null && _myCountry!.isNotEmpty) {
              query = query.eq('country', _myCountry!);
            } else if (_currentLocationScope == LocationScope.city && _myCity != null && _myCity!.isNotEmpty) {
              query = query.eq('city', _myCity!);
            }
          }
        }
      }

      if (_currentFilterIndex == 1) {
        if (_currentLocationScope == LocationScope.country && (_myCountry == null || _myCountry!.isEmpty)) {
          if (mounted) setState(() { _leaderboardData = []; _isLoadingLeaderboard = false; });
          return;
        }
        if (_currentLocationScope == LocationScope.city && (_myCity == null || _myCity!.isEmpty)) {
          if (mounted) setState(() { _leaderboardData = []; _isLoadingLeaderboard = false; });
          return;
        }
      }

      final response = await query
          .order('total_xp', ascending: false) 
          .order('current_level', ascending: false) 
          .order('current_streak', ascending: false) 
          .limit(50);
      
      if (mounted) {
        setState(() {
          _leaderboardData = List<Map<String, dynamic>>.from(response);
          _myIndex = _leaderboardData.indexWhere((user) => user['id'] == currentUser?.id);
          _isLoadingLeaderboard = false;
        });
        // Run FAB evaluation right after list builds
        WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateFabVisibility());
      }
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    }
  }

  void _showUserProfile(Map<String, dynamic> user, int rank) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = user['id'] == currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => DiscovererProfileSheet(user: user, rank: rank, isMe: isMe),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    }
  }

  void _scrollToMe() {
    if (_myIndex == -1) return;

    if (_myIndex < 3) {
      _scrollToTop();
      return;
    }

    final estimatedOffset = 220.0 + ((_myIndex - 3) * 80.0);
    
    if (_scrollController.hasClients) {
      // Offset slightly to center the user in the screen
      final target = (estimatedOffset - 150).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(target, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    _scrollController.removeListener(_evaluateFabVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, height: 1.15),
                  children: [
                    TextSpan(text: 'Top ', style: TextStyle(color: theme.colorScheme.primary)), 
                    TextSpan(text: 'Discoverers', style: TextStyle(color: theme.colorScheme.secondary)), 
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildLeaderboardFilterToggle(theme),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: _currentFilterIndex == 1 
                  ? _buildLocationSubFilters(theme)
                  : const SizedBox.shrink(),
            ),

            // Active Status Indicator Banner
            if (!_isLoadingLeaderboard && _leaderboardData.isNotEmpty)
               _buildActiveStatusBanner(theme),
            
            Expanded(
              child: _buildMainContent(theme, currentUserId, bottomInset),
            ),
          ],
        ),

        // Floating Action Buttons Layer (Glassmorphic)
        _buildSmartFloatingControls(theme, bottomInset),
      ],
    );
  }

  // --- NEW: AESTHETIC STATUS BANNER ---
  Widget _buildActiveStatusBanner(ThemeData theme) {
    String statusText = '';
    IconData statusIcon = Icons.leaderboard_rounded;

    if (_currentFilterIndex == 0) {
      statusText = _myEducationLevel != null ? 'Showing Top Explorers in $_myEducationLevel' : 'Showing All Grade Levels';
      statusIcon = Icons.school_rounded;
    } else {
      if (_currentLocationScope == LocationScope.global) {
        statusText = 'Global Leaderboard';
        statusIcon = Icons.public_rounded;
      } else if (_currentLocationScope == LocationScope.country) {
        statusText = _myCountry != null ? 'Showing Top Explorers in $_myCountry' : 'Country Leaderboard';
        statusIcon = Icons.flag_circle_rounded;
      } else if (_currentLocationScope == LocationScope.city) {
        statusText = _myCity != null ? 'Showing Top Explorers in $_myCity' : 'City Leaderboard';
        statusIcon = Icons.location_city_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: theme.colorScheme.secondary, size: 16)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(end: 1.1, duration: 1.seconds),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: GoogleFonts.montserrat(
                color: theme.colorScheme.secondary, 
                fontWeight: FontWeight.bold, 
                fontSize: 12
              ),
            ),
          ],
        ),
      ).animate(key: ValueKey('banner_$_currentFilterIndex$_currentLocationScope'))
       .fade(duration: 400.ms)
       .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
    );
  }

  // --- NEW: SMART GLASSMORPHIC FABs ---
  Widget _buildSmartFloatingControls(ThemeData theme, double bottomInset) {
    return Positioned(
      bottom: bottomInset - 40,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // GO TO ME BUTTON
          AnimatedScale(
            scale: _showGoToMe ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _showGoToMe ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildGlassFab(
                theme: theme,
                icon: Icons.person_pin_circle_rounded,
                label: 'Find Me',
                color: theme.colorScheme.secondary,
                onTap: _scrollToMe,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // GO TO TOP BUTTON
          AnimatedScale(
            scale: _showGoToTop ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _showGoToTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildGlassFab(
                theme: theme,
                icon: Icons.keyboard_double_arrow_up_rounded,
                label: 'Top',
                color: theme.colorScheme.primary,
                onTap: _scrollToTop,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassFab({
    required ThemeData theme, 
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  label, 
                  style: GoogleFonts.montserrat(
                    color: color, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, String? currentUserId, double bottomInset) {
    if (_isLoadingLeaderboard) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.secondary)
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1.seconds, color: theme.colorScheme.primary),
      );
    }

    if (_currentFilterIndex == 1) {
      if (_currentLocationScope == LocationScope.country && (_myCountry == null || _myCountry!.isEmpty)) {
        return _buildMissingLocationPrompt(theme, 'Country');
      }
      if (_currentLocationScope == LocationScope.city && (_myCity == null || _myCity!.isEmpty)) {
        return _buildMissingLocationPrompt(theme, 'City');
      }
    }

    if (_leaderboardData.isEmpty) {
      return Center(
        child: Text(
          'No explorers found in this category.', 
          style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))
        ).animate().fade().slideY(begin: 0.2),
      );
    }

    return _buildGamifiedList(currentUserId, bottomInset, theme);
  }

  Widget _buildLocationSubFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _buildSubFilterChip(theme, 'Global', LocationScope.global),
          const SizedBox(width: 8),
          _buildSubFilterChip(theme, 'Country', LocationScope.country),
          const SizedBox(width: 8),
          _buildSubFilterChip(theme, 'City', LocationScope.city),
        ],
      ).animate().fade().slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildSubFilterChip(ThemeData theme, String label, LocationScope scope) {
    final isSelected = _currentLocationScope == scope;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentLocationScope != scope) {
            setState(() => _currentLocationScope = scope);
            _fetchLeaderboard();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.secondary.withValues(alpha: 0.15) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissingLocationPrompt(ThemeData theme, String locationType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Location Required',
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'To see the leaderboard for your $locationType, you need to set it in your profile first.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to Edit Profile here!')),
                );
              },
              icon: const Icon(Icons.edit_location_alt_rounded),
              label: const Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildGamifiedList(String? currentUserId, double bottomInset, ThemeData theme) {
    final top3 = _leaderboardData.take(3).toList();
    final remaining = _leaderboardData.skip(3).toList();

    return ListView.builder(
      controller: _scrollController, 
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      itemCount: remaining.length + (top3.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        
        if (index == 0 && top3.isNotEmpty) {
          return LeaderboardPodium(
            topUsers: top3,
            onUserTap: _showUserProfile,
          ).animate().fade(duration: 600.ms).slideY(begin: 0.1);
        }

        final remainingIndex = top3.isNotEmpty ? index - 1 : index;
        final user = remaining[remainingIndex];
        final actualRank = remainingIndex + 4; 
        
        final isMe = user['id'] == currentUserId;
        final name = user['full_name'] ?? 'Anonymous Explorer';
        final xp = user['total_xp'] ?? 0;
        final displayName = isMe ? '$name (You)' : name;
        
        final avatarUrl = user['profile_picture_url'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DiscovererRowCard(
            name: displayName,
            xpLabel: '$xp XP',
            avatarUrl: avatarUrl, 
            orangeBorder: isMe ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            trophyColor: theme.colorScheme.onSurface.withValues(alpha: 0.3), 
            rank: actualRank,
            onTap: () => _showUserProfile(user, actualRank), 
          )
          .animate(key: ValueKey('leaderboard_${_filterTabController.index}_${_currentLocationScope}_$actualRank'))
          .fade(duration: 600.ms, delay: (50 * remainingIndex).ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * remainingIndex).ms),
        );
      },
    );
  }

  Widget _buildLeaderboardFilterToggle(ThemeData theme) {
    return Container(
      height: 44, 
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1.2), 
      ),
      child: TabBar(
        controller: _filterTabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.9), 
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: theme.colorScheme.onPrimary, 
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'By Grade Level'),
          Tab(text: 'By Location'),
        ],
      ),
    );
  }
}