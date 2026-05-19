import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'discovery_cards_screen.dart';
import 'widgets/lens_mastery_tracker.dart';
import 'widgets/magical_door_card.dart';

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

class _TeaserDoorsScreenState extends State<TeaserDoorsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _bgAnimController;

  final Set<String> _securedPortals = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000, viewportFraction: 0.85);

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 🚀 ANTI-CHEAT FORESHADOWING: Pre-fill secured portals from backend memory
    final preCompleted = List<String>.from(
      widget.aiData['completed_lenses'] ?? [],
    );
    _securedPortals.addAll(preCompleted);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  List<dynamic> get _teaserDoors => widget.aiData['teaser_doors'] ?? [];
  String get _objectName => widget.aiData['scanned_object'] ?? 'Unknown Object';

  // 🚀 EXTRACT THE TARGET LENSES FROM THE API
  List<String> get _questLenses =>
      List<String>.from(widget.aiData['quest_target_lenses'] ?? []);

  Future<void> _enterPortal(String lens, String teaser) async {
    final String? token =
        widget.aiData['gamification_token']; // 🚀 NEW: Extract the token
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => DiscoveryCardsScreen(
          objectName: _objectName,
          gradeLevel: widget.gradeLevel,
          selectedLens: lens,
          imagePath: widget.imagePath,
          teaserContext: teaser,
          gamificationToken: token,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _securedPortals.add(lens);
      });
    }
  }

  // Consistent Glassmorphic Card Builder
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // Profile-style Header
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _buildGlassCard(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            'CHOOSE LENS',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              shadows: [const Shadow(color: Colors.black54, blurRadius: 10)],
            ),
          ),
          const SizedBox(width: 44), // Balances the back button width
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_teaserDoors.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error', style: GoogleFonts.montserrat())),
        body: Center(
          child: Text('No pathways found.', style: GoogleFonts.inter()),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: FractionalOffset.center,
                      startAngle: 0.0,
                      endAngle: math.pi * 2,
                      colors: const [
                        Color(0x22E91E63),
                        Color(0x224CAF50),
                        Color(0x229C27B0),
                        Color(0x22E91E63),
                      ],
                      transform: GradientRotation(
                        _bgAnimController.value * math.pi * 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(), // REPLACED APPBAR WITH CONSISTENT CUSTOM HEADER
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Text(
                      _objectName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: const Color(0xFFFF8C00),
                        shadows: [
                          const Shadow(
                            color: Color(0xAAFF8C00),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LensMasteryTracker(
                  totalLenses: _teaserDoors.length,
                  securedLenses: _securedPortals.length,
                ),
                const SizedBox(height: 20),
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
                            0.85,
                            1.0,
                          );
                          final double opacity = (1 - (difference * 0.5)).clamp(
                            0.3,
                            1.0,
                          );

                          final int actualIndex = index % _teaserDoors.length;
                          final door = _teaserDoors[actualIndex];
                          final lens = door['lens'] ?? 'Unknown';

                          final isSecured = _securedPortals.contains(lens);
                          final bool isFocused = difference < 0.2;
                          // 🚀 CHECK IF THIS DOOR MATCHES A QUEST
                          final bool isQuestMatch = _questLenses.contains(lens);

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: MagicalDoorCard(
                                doorData: door,
                                isSecured: isSecured,
                                isFocused: isFocused,
                                isQuestMatch: isQuestMatch, // PASS IT DOWN
                                onEnterPortal: () => _enterPortal(
                                  lens,
                                  door['teaser_text'] ?? '',
                                ),
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
}
