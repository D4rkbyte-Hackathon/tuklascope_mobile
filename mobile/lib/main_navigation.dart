import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/navigation/main_nav_scope.dart';
import 'features/home/home_screen.dart';
import 'features/scanner/live_feed_screen.dart';
import 'features/pathways/screens/pathways_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  static const int _exploreTabIndex = 4;

  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _shineController;
  final ExploreTabController _exploreTabController = ExploreTabController();

  Timer? _inactivityTimer;
  bool _isNavBarVisible = true;
  bool _isProgrammaticScroll = false; 

  // Gesture Tracking Variables
  Offset? _dragStartPosition;
  DateTime? _lastTapTime;

  late final List<Widget> _screens = [
    const TabWrapper(rootScreen: HomeScreen()),
    const TabWrapper(rootScreen: LiveFeedScreen()),
    const TabWrapper(rootScreen: PathwaysScreen()),
    const TabWrapper(rootScreen: ProfileScreen()),
    TabWrapper(
      rootScreen: ExploreScreen(tabController: _exploreTabController),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), 
    )..repeat();

    _startInactivityTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shineController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Helper to show nav and start the auto-hide timer
  void _startInactivityTimer() {
    if (!_isNavBarVisible) {
      setState(() => _isNavBarVisible = true);
    }
    
    _inactivityTimer?.cancel();
    
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isNavBarVisible = false);
      }
    });
  }

  // Helper to forcefully hide nav immediately (e.g., when scrolling down)
  void _hideNavBar() {
    if (_isNavBarVisible) {
      setState(() => _isNavBarVisible = false);
    }
    _inactivityTimer?.cancel();
  }

  void _setNavBarVisibility(bool visible) {
    if (mounted) {
      setState(() => _isNavBarVisible = visible);
    }
    if (visible) {
      _startInactivityTimer(); 
    } else {
      _inactivityTimer?.cancel();
    }
  }

  void goToTab(int index) async {
    if (index >= 0 && index < _screens.length && _currentIndex != index) {
      _startInactivityTimer(); 
      
      setState(() {
        _currentIndex = index;
        _isProgrammaticScroll = true; 
      });
      
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      
      if (mounted) {
        _isProgrammaticScroll = false; 
      }
    }
  }

  Future<void> goToExploreLeaderboard() async {
    _startInactivityTimer();
    // Set before navigation so a lazily-mounted ExploreScreen opens on leaderboards.
    _exploreTabController.requestLeaderboard();

    if (_currentIndex != _exploreTabIndex) {
      setState(() {
        _currentIndex = _exploreTabIndex;
        _isProgrammaticScroll = true;
      });

      await _pageController.animateToPage(
        _exploreTabIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );

      if (mounted) {
        _isProgrammaticScroll = false;
      }
    }

    _exploreTabController.requestLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final bottomPadding = padding.bottom;
    final leftPadding = padding.left;
    final rightPadding = padding.right;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final baseBorderColor = theme.colorScheme.onSurface.withValues(alpha: 0.15);

    return MainNavScope(
      goToTab: goToTab,
      goToExploreLeaderboard: goToExploreLeaderboard,
      isNavBarVisible: _isNavBarVisible,
      setNavBarVisibility: _setNavBarVisibility,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        // Explore history search: keep layout height; let keyboard overlay cards.
        resizeToAvoidBottomInset: _currentIndex != 4,
        
        // Passive Raw Gesture Listener
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final now = DateTime.now();
            
            // 1. Detect Double Tap (Threshold: 300ms)
            if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 300) {
              _startInactivityTimer(); // Instantly show navbar
              _lastTapTime = null; // Reset to prevent triple-tap bugs
            } else {
              _lastTapTime = now;
            }
            
            // Record start position for scroll tracking
            _dragStartPosition = event.position;
          },
          onPointerMove: (event) {
            if (_dragStartPosition == null) return;
            
            // Calculate vertical distance moved
            final dy = event.position.dy - _dragStartPosition!.dy;
            
            // Wait for a 20 pixel threshold so micro-jitters don't trigger it
            if (dy.abs() > 20) {
              if (dy < 0) {
                // FINGER SWIPED UP (Scrolling top to bottom) -> Hide Navbar
                _hideNavBar();
              } else {
                // FINGER SWIPED DOWN (Scrolling bottom to top) -> Show Navbar
                _startInactivityTimer();
              }
              
              // Reset drag start to the current position so the check repeats smoothly
              // during a single long continuous scroll
              _dragStartPosition = event.position;
            }
          },
          onPointerUp: (_) => _dragStartPosition = null,
          onPointerCancel: (_) => _dragStartPosition = null,
          
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (!_isProgrammaticScroll) {
                    setState(() => _currentIndex = index);
                  }
                },
                children: _screens,
              ),
              
              AnimatedPositioned(
                duration: const Duration(milliseconds: 2000), 
                curve: Curves.easeOutQuint,
                bottom: _isNavBarVisible ? (16 + bottomPadding) : -120,
                left: 20 + leftPadding,
                right: 20 + rightPadding,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _isNavBarVisible ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _shineController,
                                builder: (context, child) {
                                  final slide = -3.0 + (_shineController.value * 6.0);
                                  
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      gradient: LinearGradient(
                                        begin: Alignment(slide - 1.0, -1.0),
                                        end: Alignment(slide + 1.0, 1.0),
                                        colors: [
                                          baseBorderColor, 
                                          theme.colorScheme.primary.withValues(alpha: 0.15), 
                                          theme.colorScheme.primary.withValues(alpha: 0.5), 
                                          theme.colorScheme.primary.withValues(alpha: 0.15), 
                                          baseBorderColor,
                                        ],
                                        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(1.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(33.5),
                                    color: isDark 
                                        ? Colors.black.withValues(alpha: 0.45) 
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildNavItem(Icons.home_rounded, 'Home', 0),
                                      _buildNavItem(Icons.camera_alt_rounded, 'Scan', 1),
                                      _buildNavItem(Icons.map_rounded, 'Pathways', 2),
                                      _buildNavItem(Icons.person_rounded, 'Profile', 3),
                                      _buildNavItem(Icons.explore_rounded, 'Explore', 4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    final activeColor = theme.colorScheme.tertiary; 
    final activeTextColor = theme.brightness == Brightness.dark ? const Color(0xFFFFFDF4) : theme.colorScheme.primary; 
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.4); 

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon, 
          color: isSelected ? activeColor : inactiveColor, 
          size: isSelected ? 26 : 24,
          shadows: isSelected 
              ? [BoxShadow(color: activeColor.withValues(alpha: 0.6), blurRadius: 8)] 
              : null, 
        ),
        
        if (isSelected) 
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: TextStyle(
                color: activeTextColor, 
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: activeTextColor.withValues(alpha: 0.4), blurRadius: 4) 
                ]
              ),
            ).animate().fade(duration: 200.ms).slideY(begin: 0.2, end: 0),
          ),
      ],
    );

    if (isSelected) {
      content = content.animate(key: ValueKey('nav_$index')) 
          .scaleXY(begin: 0.9, end: 1.0, duration: 300.ms, curve: Curves.easeOutBack)
          .shake(hz: 3, rotation: 0.04, offset: const Offset(0, 1.5), duration: 300.ms);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => goToTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isSelected)
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutCubic),

              content,
            ],
          ),
        ),
      ),
    );
  }
}

class TabWrapper extends StatelessWidget {
  final Widget rootScreen;
  const TabWrapper({required this.rootScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => rootScreen);
      },
    );
  }
}