import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'discovery_cards_screen.dart';

class TeaserDoorsScreen extends StatefulWidget {
  final Map<String, dynamic> aiData;
  final String imagePath;
  final String gradeLevel;

  const TeaserDoorsScreen({
    super.key,
    required this.aiData,
    required this.imagePath,
    required this.gradeLevel,
  });

  @override
  State<TeaserDoorsScreen> createState() => _TeaserDoorsScreenState();
}

class _TeaserDoorsScreenState extends State<TeaserDoorsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
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
        return Icons.science;
      case 'ABM':
        return Icons.trending_up;
      case 'HUMSS':
        return Icons.public;
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
    final theme = Theme.of(context);

    if (_teaserDoors.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No pathways found.')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 🚀 FIX: Swapped "Choose your lens" to the top, small and subtle
        title: const Text(
          'Choose your lens',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. IMMERSIVE BACKGROUND: The user's actual photo
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.scaffoldBackgroundColor,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white24,
                    size: 100,
                  ),
                ),
              ),
            ),
          ),
          // 2. LITE FROSTED OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              // 🚀 FIX: Drastically lowered blur and darkness so the photo is highly visible
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.4,
                ), // Let the photo shine through!
              ),
            ),
          ),
          // 3. MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // 🚀 FIX: Scanned Object is now here. Normal casing, normal spacing.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _objectName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0, // Normal spacing
                      color: Colors.white,
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
                          final double page =
                              _pageController.position.haveDimensions
                              ? _pageController.page!
                              : 0.0;
                          final double difference = (page - index).abs();
                          final double scale = (1 - (difference * 0.1)).clamp(
                            0.9,
                            1.0,
                          );
                          final double opacity = (1 - (difference * 0.5)).clamp(
                            0.4,
                            1.0,
                          );

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: _buildMagicalDoor(context, index, theme),
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
        ],
      ),
    );
  }

  Widget _buildMagicalDoor(BuildContext context, int index, ThemeData theme) {
    final door = _teaserDoors[index];
    final lens = door['lens'] ?? 'Unknown';
    final title = door['title'] ?? 'Mysterious Path';
    final teaser = door['teaser_text'] ?? '';
    const int xp = 50;

    final Color strandColor = _getColorForStrand(lens);
    final IconData icon = _getIconForStrand(lens);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: 0.90,
        ), // Slightly more opaque to contrast with the clearer image
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: strandColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: strandColor.withValues(alpha: 0.2),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: strandColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: strandColor, size: 36),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
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
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              lens.toUpperCase(),
              style: TextStyle(
                color: strandColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              teaser,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: strandColor,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: strandColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // 🚀 NEW: Trigger the sliding Bottom Sheet instead of a full screen push!
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Allows sheet to take up 85% height
                    backgroundColor: Colors
                        .transparent, // Required for rounded corners to show
                    builder: (context) => DiscoveryCardsScreen(
                      objectName: _objectName,
                      gradeLevel: widget.gradeLevel,
                      selectedLens: lens,
                      imagePath: widget.imagePath,
                      teaserContext: teaser,
                    ),
                  );
                },
                child: const Text(
                  'ENTER PORTAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
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
