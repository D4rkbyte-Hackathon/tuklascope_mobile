import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';
import 'features/scanner/live_feed_screen.dart';
import 'features/pathways/pathways_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/explore/explore_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Wrap each screen in our custom TabWrapper
  final List<Widget> _screens = [
    const TabWrapper(rootScreen: HomeScreen()),
    const TabWrapper(rootScreen: LiveFeedScreen()),
    const TabWrapper(rootScreen: PathwaysScreen()),
    const TabWrapper(rootScreen: ProfileScreen()),
    const TabWrapper(rootScreen: ExploreScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRITICAL: This allows the background of your screens to flow behind the rounded corners of the nav bar
      extendBody: true, 
      backgroundColor: Colors.transparent,
      
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // THE CUSTOM NAVBAR WRAPPER
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // 1. Rounded corners for the upper left and right
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          
          // 2. The Linear Gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B3C6A), // Top Color
              Color(0xFF0A233B), // Bottom Color
            ],
          ),
          
          // Optional: A soft drop shadow to lift it off the background
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        
        // ClipRRect ensures the BottomNavigationBar doesn't bleed outside our rounded container
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            
            // 3. Make the bar itself transparent so the Container's gradient shows
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            
            // 4. Set the Selected and Unselected Colors
            selectedItemColor: const Color(0xFFFF9800),   // FF9800 (Orange)
            unselectedItemColor: const Color(0xFFE0E0E0), // E0E0E0 (Light Grey)
            
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Pathways'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pathfinder'),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            ],
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