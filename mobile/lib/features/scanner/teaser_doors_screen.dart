import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your existing imports
import 'discovery_cards_screen.dart';

// The new separated widget imports
import 'widgets/nexus_uplink_node.dart';
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  List<dynamic> get _teaserDoors => widget.aiData['teaser_doors'] ?? [];
  String get _objectName => widget.aiData['scanned_object'] ?? 'Unknown Object';

  Future<void> _enterPortal(String lens, String teaser) async {
    final result = await Navigator.of(
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

    if (result == true && mounted) {
      setState(() {
        _securedPortals.add(lens);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_teaserDoors.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error', style: GoogleFonts.montserrat())),
        body: Center(
            child: Text('No pathways found.', style: GoogleFonts.inter())),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CHOOSE YOUR LENS',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 2.5,
            shadows: [
              const Shadow(color: Colors.white54, blurRadius: 15),
            ],
          ),
        ),
        centerTitle: true,
        // 🚀 UI UPGRADE: Gamified Disengage Node
        leadingWidth: 80, // Give it space to spin
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: NexusUplinkNode(onPressed: () => Navigator.of(context).pop()),
          ),
        ),
      ),
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
                          _bgAnimController.value * math.pi * 2),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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

                          final double scale =
                              (1 - (difference * 0.1)).clamp(0.85, 1.0);
                          final double opacity =
                              (1 - (difference * 0.5)).clamp(0.3, 1.0);

                          final int actualIndex = index % _teaserDoors.length;
                          final door = _teaserDoors[actualIndex];
                          final lens = door['lens'] ?? 'Unknown';
                          final isSecured = _securedPortals.contains(lens);
                          final bool isFocused = difference < 0.2;

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: MagicalDoorCard(
                                doorData: door,
                                isSecured: isSecured,
                                isFocused: isFocused,
                                onEnterPortal: () => _enterPortal(
                                    lens, door['teaser_text'] ?? ''),
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