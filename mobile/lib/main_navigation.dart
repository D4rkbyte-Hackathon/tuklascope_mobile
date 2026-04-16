import 'dart:async'; 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 

import 'core/navigation/main_nav_scope.dart';
import 'features/home/home_screen.dart';
import 'features/scanner/live_feed_screen.dart';
import 'features/pathways/pathways_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/explore/explore_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  // --- STATE VARIABLES ---
  Timer? _inactivityTimer;
  bool _isNavBarVisible = true;
  bool _isProgrammaticScroll = false; // 1. Added anti-glitch lock

  final List<Widget> _screens = [
    const TabWrapper(rootScreen: HomeScreen()),
    const TabWrapper(rootScreen: LiveFeedScreen()),
    const TabWrapper(rootScreen: PathwaysScreen()),
    const TabWrapper(rootScreen: ProfileScreen()),
    const TabWrapper(rootScreen: ExploreScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

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

  // 2. REFACTORED GOTOTAB LOGIC
  void goToTab(int index) async {
    if (index >= 0 && index < _screens.length && _currentIndex != index) {
      _startInactivityTimer(); 
      
      setState(() {
        _currentIndex = index;
        _isProgrammaticScroll = true; // Lock the physical swipe listener
      });
      
      // Wait for the page slide animation to completely finish
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      
      // Unlock the listener so physical swiping works again
      if (mounted) {
        _isProgrammaticScroll = false; 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return MainNavScope(
      goToTab: goToTab,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        
        body: Listener(
          onPointerDown: (_) => _startInactivityTimer(),
          onPointerMove: (_) => _startInactivityTimer(),
          onPointerUp: (_) => _startInactivityTimer(),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  // 3. IGNORE INTERMEDIATE SCREENS DURING ANIMATION
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
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _isNavBarVisible ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A233B).withOpacity(0.75),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildNavItem(Icons.home_rounded, 'Home', 0),
                            _buildNavItem(Icons.camera_alt_rounded, 'Scan', 1),
                            _buildNavItem(Icons.map_rounded, 'Pathways', 2),
                            _buildNavItem(Icons.person_rounded, 'Pathfinder', 3),
                            _buildNavItem(Icons.explore_rounded, 'Explore', 4),
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
    final activeColor = const Color(0xFFFF9800); 
    final inactiveColor = const Color(0xFFE0E0E0).withOpacity(0.5);

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon, 
          color: isSelected ? activeColor : inactiveColor, 
          size: isSelected ? 26 : 24,
          shadows: isSelected 
              ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 8)] 
              : null, 
        ),
        
        if (isSelected) 
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: TextStyle(
                color: activeColor,
                fontSize: 10, 
                fontWeight: FontWeight.w700,
              ),
            ).animate().fade(duration: 200.ms).slideY(begin: -0.2, end: 0),
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
          child: content,
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