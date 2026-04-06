import 'package:flutter/material.dart';
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

  // Wrap each screen in our custom TabWrapper
  final List<Widget> _screens = [
    const TabWrapper(rootScreen: HomeScreen()),
    const TabWrapper(rootScreen: LiveFeedScreen()),
    const TabWrapper(rootScreen: PathwaysScreen()),
    const TabWrapper(rootScreen: ProfileScreen()),
    const TabWrapper(rootScreen: ExploreScreen()),
  ];

  /// Switches the bottom navigation tab (`0` home, `1` scan, `2` pathways, `3` profile, `4` explore).
  void goToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainNavScope(
      goToTab: goToTab,
      child: Scaffold(
        // CRITICAL: This allows the background of your screens to flow behind the rounded corners of the nav bar
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B3C6A), Color(0xFF0A233B)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFFF9800),
              unselectedItemColor: const Color(0xFFE0E0E0),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Pathways',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Pathfinder',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// THE MAGIC TRICK: Keeps the bottom nav visible during secondary screen pushes
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
