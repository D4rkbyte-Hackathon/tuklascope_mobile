import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../../core/navigation/main_nav_scope.dart'; 
import '../scanner/tuklas_tutor_screen.dart'; 
import '../auth/presentation/screens/login_screen.dart'; // ADDED: Import the Login Screen

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Color primaryBlue = const Color(0xFF0B3C6A);
  final Color secondaryBlue = const Color(0xFF0A233B); 
  final Color accentOrange = const Color(0xFFFF6B2C);
  final Color darkGreen = const Color(0xFF2E7D32); 
  final Color textLight = const Color(0xFF4A4A4A);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color bgLight = const Color(0xFFFFFDF4); 
  final Color bgDark = const Color(0xFFD9D7CE);

  @override
  Widget build(BuildContext context) {
    final List<Widget> listItems = [
      _buildDailyQuestCard(),
      const SizedBox(height: 32),
      
      _buildHeroHeading('Discover', 'Everything'),
      const SizedBox(height: 16),
      
      Text(
        'Transform any object around you into a learning adventure. Take a photo and unlock the science behind everyday life!',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textLight, fontSize: 16),
      ),
      const SizedBox(height: 32),

      _buildInfoCard(
        title: 'Tuklas-Araw',
        description: 'Explore the science behind Filipino rice terraces - How do these ancient structures demonstrate physics and engineering?',
        borderColor: accentOrange,
        buttonText: 'Ask TuklasTutor about this →',
        buttonGradient: [primaryBlue, secondaryBlue],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuklasTutorScreen())),
      ),
      const SizedBox(height: 24),

      _buildDiscoverySection(),
      const SizedBox(height: 48),

      _buildHeroHeading('Explore Your', 'Learning\nJourney', isStacked: true),
      const SizedBox(height: 16),
      
      Text(
        'Track your progress, discover new pathways, and get personalized guidance for your academic journey.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textLight, fontSize: 16),
      ),
      const SizedBox(height: 32),

      _buildFeatureCard(
        title: 'Learning Pathways',
        description: 'Structured learning journeys\nfrom beginner to advanced levels',
        borderColor: primaryBlue,
        buttonText: 'Explore Pathways →',
        buttonTextColor: primaryBlue,
        iconArea: const Icon(Icons.map_outlined, size: 64, color: Color(0xFF0B3C6A)),
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(2), 
      ),
      const SizedBox(height: 24),

      _buildFeatureCard(
        title: 'The "Kaalaman" Skill Tree',
        description: 'Track your progress, discover new pathways,\nand get personalized guidance for your journey.',
        borderColor: darkGreen,
        buttonText: 'View Pathfinder →',
        buttonTextColor: darkGreen,
        iconArea: Icon(Icons.account_tree_outlined, size: 64, color: darkGreen),
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(3), 
      ),
      const SizedBox(height: 24),

      _buildFeatureCard(
        title: 'Tuklascope AI', 
        description: 'Get personalized career and academic\nguidance based on your skills',
        borderColor: const Color(0xFF8E24AA),
        buttonText: 'Get Guidance →',
        buttonTextColor: const Color(0xFF8E24AA),
        iconArea: const Icon(Icons.auto_awesome_outlined, size: 64, color: Color(0xFF8E24AA)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuklasTutorScreen())),
      ),
      const SizedBox(height: 60), 
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgLight, bgDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, MediaQuery.paddingOf(context).bottom + 110),
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  final item = listItems[index];
                  if (item is SizedBox) return item; 
                  
                  return item
                      .animate()
                      .fade(duration: 600.ms, delay: (50 * (index % 10)).ms) 
                      .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * (index % 10)).ms);
                },
              ),

              // --- UPDATED DEBUG LOGOUT BUTTON ---
              Positioned(
                top: 8,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    tooltip: 'Debug Logout',
                    onPressed: () {
                      // ADDED 'rootNavigator: true' TO DESTROY THE BOTTOM NAV BAR
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildDailyQuestCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Daily Discovery Quest',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: textLight, 
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '0/3 Discovered',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('69', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: accentOrange)),
                    const SizedBox(height: 4),
                    Text('Daily Streak', style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey[400]), 
              Expanded(
                child: Column(
                  children: [
                    Text('420', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryBlue)),
                    const SizedBox(height: 4),
                    Text('Total Points', style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeroHeading(String part1, String part2, {bool isStacked = false}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.2),
        children: [
          TextSpan(text: '$part1 ', style: TextStyle(color: primaryBlue)),
          if (isStacked)
            TextSpan(text: '\n$part2', style: TextStyle(color: accentOrange))
          else
            TextSpan(text: part2, style: TextStyle(color: accentOrange)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required Color borderColor,
    required String buttonText,
    required List<Color> buttonGradient,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentOrange),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: textDark, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildGradientButton(buttonText, buttonGradient, onTap: onTap),
        ],
      ),
    );
  }

  Widget _buildDiscoverySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What will you discover today?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a photo or\nuse your camera to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textLight, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          _buildGradientButton(
            'Start Discovery →', 
            [const Color(0xFFFF9800), const Color(0xFFA1640B)], 
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            onTap: () {
              MainNavScope.maybeOf(context)?.goToTab(1);
            }
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required Color borderColor,
    required String buttonText,
    required Color buttonTextColor,
    required Widget iconArea,
    required VoidCallback onTap, 
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          SizedBox(height: 100, child: Center(child: iconArea)),
          const SizedBox(height: 16),
          
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textLight)),
          const SizedBox(height: 8),
          
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: textLight, height: 1.4)),
          const SizedBox(height: 24),
          
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(buttonText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: buttonTextColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, List<Color> gradientColors, {EdgeInsetsGeometry? padding, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap, 
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}