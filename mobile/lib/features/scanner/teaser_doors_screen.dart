import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'discovery_cards_screen.dart';

class TeaserDoorsScreen extends StatelessWidget {
  const TeaserDoorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Updated the Data with Strands, Icons (Gear, Chart, Quill, Hammer), and Subtitles
    final List<Map<String, dynamic>> doors = [
      {
        'title': 'STEM',
        'icon': Icons.settings, // Gear icon
        'subtitle': 'Explore the logical realms of Science, Technology, Engineering, and Math.'
      },
      {
        'title': 'ABM',
        'icon': Icons.bar_chart, // Chart icon
        'subtitle': 'Master the principles of Accountancy, Business, and Management.'
      },
      {
        'title': 'HUMSS',
        'icon': Icons.history_edu, // Quill icon
        'subtitle': 'Dive deep into Humanities, Education, and the Social Sciences.'
      },
      {
        'title': 'TVL',
        'icon': Icons.handyman, // Hammer icon
        'subtitle': 'Gain hands-on, practical skills in Technical-Vocational Livelihood.'
      },
    ];

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Select a Pathway',
          style: TextStyle(color: Color(0xFF0B3C6A), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0B3C6A)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // 2. The Dual-Colored Text using RichText
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto', // Change if you have a custom font in pubspec
                ),
                children: [
                  TextSpan(
                    text: 'Enter a ',
                    style: TextStyle(color: Color(0xFF0B3C6A)), // Dark Blue
                  ),
                  TextSpan(
                    text: 'Door',
                    style: TextStyle(color: Color(0xFFFF6B2C)), // New Orange Color
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // 3. Updated Strand-specific subtitle
            Text(
              'The artifact resonates with multiple disciplines. Choose a strand to reveal its hidden knowledge and career pathways.',
              style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
            ),
            const SizedBox(height: 30),
            
            // THE 2x2 GRID
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: doors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16, 
                  mainAxisSpacing: 16, 
                  childAspectRatio: 0.85, 
                ),
                itemBuilder: (context, index) {
                  final door = doors[index];
                  return _buildGridCard(
                    context,
                    door['title'],
                    door['icon'],
                    door['subtitle'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The Reusable Grid Card Widget (Unchanged)
  Widget _buildGridCard(BuildContext context, String title, IconData icon, String subtitle) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscoveryCardsScreen(title: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800), 
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C6A), 
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}