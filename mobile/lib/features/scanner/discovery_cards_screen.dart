import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';

// --- MOCK DATA ---
const _mockData = {
  'title': "Magellan's Cross",
  'rating': "4.8",
  'image':
      'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=1000&auto=format&fit=crop',
  'sections': {
    'about':
        "Magellan's Cross is a Christian cross planted by Portuguese and Spanish explorers as ordered by Ferdinand Magellan upon arriving in Cebu in the Philippines on April 21, 1521.",
    'significance':
        "This site is a symbol of the birth of Christianity in the land. It houses the original cross inside a tindalo wood case to protect it.",
    'history':
        "The kiosk that houses the cross was built in 1834. The ceiling of the kiosk is painted with a mural depicting the baptism of Rajah Humabon.",
  },
};

// Changed to StatefulWidget to handle tab switching!
class DiscoveryCardsScreen extends StatefulWidget {
  // NEW: We are now demanding these three pieces of data!
  final String objectName;
  final String gradeLevel;
  final String selectedLens;

  // Notice we removed 'title', and added the three new variables
  const DiscoveryCardsScreen({
    super.key,
    required this.objectName,
    required this.gradeLevel,
    required this.selectedLens,
  });

  @override
  State<DiscoveryCardsScreen> createState() => _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends State<DiscoveryCardsScreen> {
  // State variable to track which button is selected (0, 1, or 2)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // We add a subtle dark drop shadow to the white icons so they are visible over ANY image
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HERO IMAGE WITH LIGHT FADE ---
            SizedBox(
              height: 350, // Slightly shorter so we get to the content faster
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _mockData['image'] as String,
                    fit: BoxFit.cover,
                  ),
                  // The gradient fade that blends the image into your LIGHT background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45, // Dark top for the AppBar icons
                          Colors.transparent,
                          Color(
                            0xFFFFFDF4,
                          ), // Fades seamlessly into your app's top background color!
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. CONTENT AREA ---
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.selectedLens.toUpperCase()}: ${widget.objectName}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(
                                0xFF0B3C6A,
                              ), // Dark Blue for contrast
                              height: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800), // Orange
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _mockData['rating'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- 3. THE 3 INTERACTIVE TABS ---
                    Row(
                      children: [
                        _buildTabButton(0, 'Quick Fact', Icons.bolt),
                        const SizedBox(width: 8),
                        _buildTabButton(1, 'Concepts', Icons.lightbulb_outline),
                        const SizedBox(width: 8),
                        _buildTabButton(
                          2,
                          'Hands-on',
                          Icons.build_circle_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- 4. THE DYNAMIC CONTENT CARD ---
                    // This seamlessly switches out the card based on which button you tapped
                    _buildActiveCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: TAB BUTTONS ---
  Widget _buildTabButton(int index, String label, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Tell Flutter to rebuild the screen with the new active tab
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF0B3C6A).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF0B3C6A),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF0B3C6A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: DYNAMIC CONTENT SWITCHER ---
  Widget _buildActiveCard() {
    switch (_selectedIndex) {
      case 0:
        return _buildGlassSection(
          'Quick Fact',
          (_mockData['sections'] as Map<String, String>)['about']!,
        );
      case 1:
        return _buildGlassSection(
          'Concepts',
          (_mockData['sections'] as Map<String, String>)['significance']!,
        );
      case 2:
        return _buildGlassSection(
          'Hands-on Project',
          (_mockData['sections'] as Map<String, String>)['history']!,
        );
      default:
        return const SizedBox();
    }
  }

  // --- HELPER: LIGHT THEME GLASS CARD ---
  Widget _buildGlassSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Light Frosted Glass
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2), // Crisp white edge
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800), // Orange section headers
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800], // Dark gray for excellent readability
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
