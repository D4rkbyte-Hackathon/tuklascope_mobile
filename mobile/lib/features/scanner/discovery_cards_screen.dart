// mobile/lib/features/scanner/discovery_cards_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
// NEW: Import the service we just made
import 'package:tuklascope_mobile/core/services/learn_service.dart';

class DiscoveryCardsScreen extends StatefulWidget {
  final String objectName;
  final String gradeLevel;
  final String selectedLens;

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
  int _selectedIndex = 0;

  // NEW: State variables for network handling
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;

  @override
  void initState() {
    super.initState();
    // NEW: Fetch the data the moment the screen opens
    _fetchLearningDeck();
  }

  // NEW: The network call
  Future<void> _fetchLearningDeck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final data = await LearnService.generateDeck(
      objectName: widget.objectName,
      gradeLevel: widget.gradeLevel,
      selectedLens: widget.selectedLens,
    );

    if (!mounted) return;

    if (data != null) {
      setState(() {
        _deckData = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error =
            'Failed to generate the learning deck. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      // NEW: Handle Loading and Error States gracefully
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0B3C6A)),
                  SizedBox(height: 16),
                  Text(
                    'Generating custom lesson...',
                    style: TextStyle(
                      color: Color(0xFF0B3C6A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchLearningDeck,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(), // Show your UI if successful!
    );
  }

  // YOUR EXACT ORIGINAL UI LAYOUT
  Widget _buildContent() {
    // Safely extract data with fallbacks
    final xpReward = _deckData?['xp_reward']?.toString() ?? '50';
    // Fallback to a generic abstract learning image if the AI doesn't provide a specific URL
    final imageUrl =
        _deckData?['image_url'] ??
        'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=1000&auto=format&fit=crop';

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- 1. HERO IMAGE WITH LIGHT FADE ---
          SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // Handle broken image links gracefully
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300]),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black45,
                        Colors.transparent,
                        Color(0xFFFFFDF4),
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
                            color: Color(0xFF0B3C6A),
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
                          color: const Color(0xFFFF9800),
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
                              '+$xpReward XP', // NEW: Dynamic XP!
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
                  _buildActiveCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
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

  Widget _buildActiveCard() {
    // NEW: Safely grab the AI generated text for each section
    final quickFact =
        _deckData?['quick_fact'] ??
        "A fascinating fact about this artifact is currently hidden.";
    final concept =
        _deckData?['core_concept'] ??
        "The underlying principles are still waiting to be discovered.";
    final handsOn =
        _deckData?['practical_application'] ??
        "Try finding a way to apply this in your local community!";

    switch (_selectedIndex) {
      case 0:
        return _buildGlassSection('Quick Fact', quickFact);
      case 1:
        return _buildGlassSection('Concepts', concept);
      case 2:
        return _buildGlassSection('Hands-on Project', handsOn);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGlassSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
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
              color: Color(0xFFFF9800),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
