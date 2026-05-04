import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // 🚀 NEW: State tracker to lock completed portals
  final Set<String> _securedPortals = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000, viewportFraction: 0.85);
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
        appBar: AppBar(title: Text('Error', style: GoogleFonts.montserrat())),
        body: Center(child: Text('No pathways found.', style: GoogleFonts.inter())),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Choose your lens',
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _objectName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          final double page =
                              _pageController.position.haveDimensions
                                  ? _pageController.page!
                                  : 1000.0;
                          final double difference = (page - index).abs();
                          final double scale = (1 - (difference * 0.1)).clamp(
                            0.9,
                            1.0,
                          );
                          final double opacity = (1 - (difference * 0.5)).clamp(
                            0.4,
                            1.0,
                          );
                          final int actualIndex = index % _teaserDoors.length;

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: _buildMagicalDoor(
                                context,
                                actualIndex,
                                theme,
                              ),
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

    // Check if this specific lens has already been completed
    final bool isSecured = _securedPortals.contains(lens);

    final Color strandColor = isSecured
        ? Colors.green
        : _getColorForStrand(lens);
    final IconData icon = isSecured
        ? Icons.check_circle
        : _getIconForStrand(lens);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: strandColor.withValues(alpha: isSecured ? 1.0 : 0.5),
          width: isSecured ? 3 : 2,
        ),
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
                    color: isSecured
                        ? Colors.green.withValues(alpha: 0.15)
                        : theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSecured
                          ? Colors.green
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSecured ? Icons.lock : Icons.star_rounded,
                        color: isSecured
                            ? Colors.green
                            : const Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSecured ? 'SECURED' : '+$xp XP',
                        style: GoogleFonts.orbitron(
                          color: isSecured
                              ? Colors.green
                              : theme.colorScheme.primary,
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
              style: GoogleFonts.orbitron(
                color: strandColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSecured ? "Data Extracted" : title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              isSecured
                  ? "You have successfully absorbed the knowledge from this pathway. Choose another lens to continue extracting."
                  : teaser,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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
                  backgroundColor: isSecured ? Colors.transparent : strandColor,
                  foregroundColor: isSecured ? Colors.green : Colors.white,
                  elevation: isSecured ? 0 : 5,
                  shadowColor: strandColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSecured ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                onPressed: isSecured
                    ? null
                    : () async {
                        // 🚀 WAIT FOR THE DECK TO RETURN TRUE IF SUCCESSFUL
                        final result =
                            await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push(
                              MaterialPageRoute(
                                builder: (context) => DiscoveryCardsScreen(
                                  objectName: _objectName,
                                  gradeLevel: widget.gradeLevel,
                                  selectedLens: lens,
                                  imagePath: widget.imagePath,
                                  teaserContext: teaser,
                                ),
                              ),
                            );

                        // 🚀 IF SUCCESSFUL, LOCK THIS PORTAL!
                        if (result == true && mounted) {
                          setState(() {
                            _securedPortals.add(lens);
                          });
                        }
                      },
                child: Text(
                  isSecured ? 'PORTAL CLOSED' : 'ENTER PORTAL',
                  style: GoogleFonts.inter(
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