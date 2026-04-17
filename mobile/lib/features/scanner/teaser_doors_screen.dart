// mobile/lib/features/scanner/teaser_doors_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'discovery_cards_screen.dart';

class TeaserDoorsScreen extends StatefulWidget {
  final Map<String, dynamic> aiData;
  final String
  imagePath; // 🚀 NEW: We need to receive this from the Camera/LiveFeed

  const TeaserDoorsScreen({
    super.key,
    required this.aiData,
    required this.imagePath, // 🚀 NEW
  });

  @override
  State<TeaserDoorsScreen> createState() => _TeaserDoorsScreenState();
}

class _TeaserDoorsScreenState extends State<TeaserDoorsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<dynamic> get _teaserDoors => widget.aiData['teaser_doors'] ?? [];
  String get _objectName => widget.aiData['scanned_object'] ?? 'Unknown Object';

  IconData _getIconForStrand(String lens) {
    switch (lens.toUpperCase()) {
      case 'STEM':
        return Icons.settings;
      case 'ABM':
        return Icons.bar_chart;
      case 'HUMSS':
        return Icons.history_edu;
      case 'TVL':
        return Icons.handyman;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getColorForStrand(String lens) {
    switch (lens.toUpperCase()) {
      case 'STEM':
        return const Color(0xFFE91E63);
      case 'ABM':
        return const Color(0xFF4CAF50);
      case 'HUMSS':
        return const Color(0xFFFF9800);
      case 'TVL':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF0B3C6A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_teaserDoors.isEmpty) {
      return GradientScaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No pathways found.')),
      );
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          _objectName,
          style: const TextStyle(
            color: Color(0xFF0B3C6A),
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0B3C6A)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: 'Open a ',
                    style: TextStyle(color: Color(0xFF0B3C6A)),
                  ),
                  TextSpan(
                    text: 'Door',
                    style: TextStyle(color: Color(0xFFFF6B2C)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Swipe to explore the hidden knowledge within this artifact.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _teaserDoors.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      // 🚀 FIX: Added 'final' to these local variables
                      final double page =
                          _pageController.position.haveDimensions
                          ? _pageController.page!
                          : 0.0;
                      final double difference = (page - index).abs();
                      final double scale = (1 - (difference * 0.15)).clamp(
                        0.85,
                        1.0,
                      );
                      final double opacity = (1 - (difference * 0.4)).clamp(
                        0.4,
                        1.0,
                      );

                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: _buildMagicalDoor(context, index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMagicalDoor(BuildContext context, int index) {
    final door = _teaserDoors[index];
    final lens = door['lens'] ?? 'Unknown';
    final title = door['title'] ?? 'Mysterious Path';
    final teaser = door['teaser_text'] ?? '';
    final xp = door['estimated_xp'] ?? 50;

    final Color strandColor = _getColorForStrand(lens);
    final IconData icon = _getIconForStrand(lens);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        // 🚀 FIX: Used withValues(alpha: X)
        border: Border.all(color: strandColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: strandColor.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // 🚀 FIX: Used withValues(alpha: X)
                    color: strandColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: strandColor, size: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3C6A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$xp XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              lens.toUpperCase(),
              style: TextStyle(
                color: strandColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C6A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), thickness: 2),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  teaser,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: strandColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscoveryCardsScreen(
                        objectName: _objectName,
                        gradeLevel: widget.aiData['grade_level'] ?? '',
                        selectedLens: lens,
                        imagePath: widget
                            .imagePath, // 🚀 FIX: Passed the path through!
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Step Through',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
