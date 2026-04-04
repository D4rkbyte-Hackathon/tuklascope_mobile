import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORT YOUR DESTINATION SCREENS ---
import '../scanner/live_feed_screen.dart';
import '../pathways/pathways_screen.dart';
import '../profile/profile_screen.dart';

// --- AUTH IMPORTS FOR DEBUG LOGOUT ---
import '../auth/providers/auth_provider.dart';
import '../onboarding/splash_screen.dart';

// Upgraded to ConsumerWidget to access Riverpod's 'ref'
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // --- EXACT COLOR PALETTE ---
  static const Color kDarkBlue = Color(0xFF0B3C6A);
  static const Color kOrange = Color(0xFFFF6B2C);
  static const Color kCardBg = Color(0xFFFFFDF4);
  static const Color kLightBlue = Color(0xFF64B5F6);
  static const Color kGreen = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. THE QUEST BAR (STREAK, XP & DEBUG LOGOUT) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kDarkBlue,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatBadge(Icons.local_fire_department_rounded, '12', kOrange),
                      const SizedBox(width: 8),
                      _buildStatBadge(Icons.diamond_rounded, '1,250 XP', kLightBlue),
                      
                      // THE DEBUG LOGOUT BUTTON
                      IconButton(
                        icon: const Icon(Icons.logout, color: kDarkBlue),
                        tooltip: 'Debug Logout',
                        onPressed: () async {
                          // A. Kill the Supabase session
                          await ref.read(authServiceProvider).signOut();

                          // B. Nuke the navigation stack and go to Splash
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const SplashScreen()),
                              (route) => false, 
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 2. DISCOVER EVERYTHING SECTION ---
              const Text(
                'Discover Everything',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kDarkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transform any object around you into a learning adventure. Take a photo and unlock the science behind everyday life!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // THE 2-COLUMN GRID (Tuklas Araw & Discovery)
              Row(
                children: [
                  Expanded(
                    child: _buildSquareCard(
                      context: context,
                      title: 'Tuklas Araw',
                      icon: Icons.wb_sunny_rounded,
                      buttonColor: kGreen,
                      buttonText: 'Daily Scan',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tuklas Araw coming soon!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSquareCard(
                      context: context,
                      title: 'Discovery',
                      icon: Icons.document_scanner_rounded,
                      buttonColor: kOrange,
                      buttonText: 'Scan Now',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LiveFeedScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- 3. EXPLORE YOUR LEARNING JOURNEY SECTION ---
              const Text(
                'Explore Your Learning Journey',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kDarkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your progress, discover new pathways, and get personalized guidance for your academic journey.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // THE VERTICAL WIDE CARDS
              _buildWideCard(
                context: context,
                title: 'Learning Pathways',
                subtitle: 'Follow structured modules tailored to your SHS strand.',
                icon: Icons.map_outlined,
                accentColor: kLightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PathwaysScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _buildWideCard(
                context: context,
                title: 'Kaalaman Skill Tree',
                subtitle: 'View your mastered skills and unlock new nodes.',
                icon: Icons.account_tree_outlined,
                accentColor: kGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildWideCard(
                context: context,
                title: 'Pathfinder AI',
                subtitle: 'Ask questions and get intelligent study recommendations.',
                icon: Icons.auto_awesome,
                accentColor: kOrange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pathfinder AI coming soon!')),
                  );
                },
              ),
              
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: STAT BADGE (STREAK/XP) ---
  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: SQUARE CARDS (TOP ROW) ---
  Widget _buildSquareCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color buttonColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: buttonColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkBlue,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: WIDE CARDS (BOTTOM LIST) ---
  Widget _buildWideCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}