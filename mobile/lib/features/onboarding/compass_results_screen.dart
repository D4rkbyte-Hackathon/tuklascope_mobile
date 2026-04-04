import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../main_navigation.dart';

class CompassResultsScreen extends StatelessWidget {
  const CompassResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Optional: Hide the back button if you don't want them retaking it immediately
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // --- 1. DUAL-COLORED HEADING ---
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    fontFamily: 'Roboto', // Standard Flutter font
                  ),
                  children: [
                    TextSpan(
                      text: 'Your Journey\n',
                      style: TextStyle(color: Color(0xFF0B3C6A)), // Dark Blue
                    ),
                    TextSpan(
                      text: 'Begins',
                      style: TextStyle(color: Color(0xFFFF6B2C)), // Tuklascope Orange
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. THE RESULT CARD ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // THE GEAR ICON
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B2C).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings, // Gear
                          size: 64,
                          color: Color(0xFFFF6B2C), // Orange
                        ),
                      ),
                      const SizedBox(height: 24),

                      // THE PERSONA TITLE
                      const Text(
                        'The Innovator',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B3C6A), // Dark Blue
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'STEM / TVL Affinity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 24),

                      // --- 3. FAKE STATS SECTION ---
                      _buildStatRow('Logic & Analysis', 0.92),
                      const SizedBox(height: 16),
                      _buildStatRow('Practical Building', 0.85),
                      const SizedBox(height: 16),
                      _buildStatRow('Creative Problem Solving', 0.78),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 4. START JOURNEY BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to MainNavigation and wipe the onboarding history!
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B2C), // Orange
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFF6B2C).withOpacity(0.5),
                  ),
                  child: const Text(
                    'Start Your Discovery Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Safe area bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: STAT PROGRESS BARS ---
  Widget _buildStatRow(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C6A),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B2C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 1,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2C)), // Orange fill
          ),
        ),
      ],
    );
  }
}