import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
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

class _TeaserDoorsScreenState extends State<TeaserDoorsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _bgAnimController;

  // 🚀 EXISTING LOGIC: State tracker to lock completed portals
  final Set<String> _securedPortals = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000, viewportFraction: 0.85);
    
    // Ambient background rotation controller
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

  // 🚀 EXISTING LOGIC: Portal entry handler
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
        body: Center(child: Text('No pathways found.', style: GoogleFonts.inter())),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // UI UPGRADE 3: Prominent Title
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
        // UI UPGRADE 4: Alive Back Button
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AnimatedBackButton(onPressed: () => Navigator.of(context).pop()),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
          
          // Base Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),

          // Ambient Animated Atmosphere
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
                      transform: GradientRotation(_bgAnimController.value * math.pi * 2),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main UI Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Text Element
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
                    // UI UPGRADE 2: Iconic Orange Object Name
                    child: Text(
                      _objectName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: const Color(0xFFFF8C00), // Iconic App Orange
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
                
                // UI UPGRADE 5: Gamification Visual Tracker
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
                          final double page = _pageController.position.haveDimensions
                              ? _pageController.page!
                              : 1000.0;
                          final double difference = (page - index).abs();
                          
                          final double scale = (1 - (difference * 0.1)).clamp(0.85, 1.0);
                          final double opacity = (1 - (difference * 0.5)).clamp(0.3, 1.0);
                          
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
                                onEnterPortal: () => _enterPortal(lens, door['teaser_text'] ?? ''),
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

// ============================================================================
// UI UPGRADE 5: Gamification Mastery Tracker Segment
// ============================================================================
class LensMasteryTracker extends StatelessWidget {
  final int totalLenses;
  final int securedLenses;

  const LensMasteryTracker({
    super.key,
    required this.totalLenses,
    required this.securedLenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalLenses, (index) {
            final bool isUnlocked = index < securedLenses;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isUnlocked ? 35 : 20, // Expands when unlocked
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.greenAccent : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isUnlocked
                    ? [
                        const BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          "$securedLenses / $totalLenses FRAGMENTS EXTRACTED",
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// UI UPGRADE 4: Alive Breathing Back Button
// ============================================================================
class AnimatedBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedBackButton({super.key, required this.onPressed});

  @override
  State<AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<AnimatedBackButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2 + (_pulseController.value * 0.3)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1 * _pulseController.value),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

// ============================================================================
// Upgraded Magical Door Card with Float & Glow
// ============================================================================
class MagicalDoorCard extends StatefulWidget {
  final Map<String, dynamic> doorData;
  final bool isSecured;
  final bool isFocused;
  final VoidCallback onEnterPortal;

  const MagicalDoorCard({
    super.key,
    required this.doorData,
    required this.isSecured,
    required this.isFocused,
    required this.onEnterPortal,
  });

  @override
  State<MagicalDoorCard> createState() => _MagicalDoorCardState();
}

class _MagicalDoorCardState extends State<MagicalDoorCard> with SingleTickerProviderStateMixin {
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  IconData _getIconForStrand(String lens) {
    switch (lens.toUpperCase()) {
      case 'STEM': return Icons.science;
      case 'ABM': return Icons.trending_up;
      case 'HUMSS': return Icons.public;
      case 'TVL': return Icons.handyman;
      default: return Icons.lightbulb;
    }
  }

  Color _getColorForStrand(String lens) {
    switch (lens.toUpperCase()) {
      case 'STEM': return const Color(0xFFE91E63);
      case 'ABM': return const Color(0xFF4CAF50);
      case 'HUMSS': return const Color(0xFFFF9800);
      case 'TVL': return const Color(0xFF9C27B0);
      default: return const Color(0xFF0B3C6A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lens = widget.doorData['lens'] ?? 'Unknown';
    final title = widget.doorData['title'] ?? 'Mysterious Path';
    final teaser = widget.doorData['teaser_text'] ?? '';
    const int xp = 50;

    final Color strandColor = widget.isSecured ? Colors.greenAccent : _getColorForStrand(lens);
    final IconData icon = widget.isSecured ? Icons.verified : _getIconForStrand(lens);

    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        final double floatOffset = widget.isFocused ? math.sin(_idleController.value * math.pi) * 8 : 0;
        final double glowSpread = widget.isFocused ? 5 + (_idleController.value * 10) : 5;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.95),
                  theme.colorScheme.surface.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: strandColor.withValues(alpha: widget.isSecured ? 1.0 : 0.6),
                width: widget.isSecured ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: strandColor.withValues(alpha: widget.isFocused ? 0.3 : 0.1),
                  blurRadius: 30,
                  spreadRadius: glowSpread,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                              border: Border.all(
                                color: strandColor.withValues(alpha: 0.3),
                              )
                            ),
                            child: Icon(icon, color: strandColor, size: 36),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.isSecured
                                  ? Colors.greenAccent.withValues(alpha: 0.15)
                                  : theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.isSecured
                                    ? Colors.greenAccent
                                    : theme.colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.isSecured ? Icons.lock_open : Icons.auto_awesome,
                                  color: widget.isSecured ? Colors.greenAccent : const Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.isSecured ? 'EXTRACTED' : '+$xp XP',
                                  style: GoogleFonts.orbitron(
                                    color: widget.isSecured ? Colors.greenAccent : theme.colorScheme.primary,
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
                          letterSpacing: 3,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: strandColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                            )
                          ]
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.isSecured ? "Data Fully Assimilated" : title,
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
                        widget.isSecured
                            ? "You have successfully absorbed the knowledge from this pathway. Choose another lens to continue extracting."
                            : teaser,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: AnimatedShimmerButton(
                          isSecured: widget.isSecured,
                          strandColor: strandColor,
                          onPressed: widget.isSecured ? null : widget.onEnterPortal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

// ============================================================================
// UI UPGRADE 1: Extracted Full-Button Sweeping Shine Effect
// ============================================================================
class AnimatedShimmerButton extends StatefulWidget {
  final bool isSecured;
  final Color strandColor;
  final VoidCallback? onPressed;

  const AnimatedShimmerButton({
    super.key,
    required this.isSecured,
    required this.strandColor,
    required this.onPressed,
  });

  @override
  State<AnimatedShimmerButton> createState() => _AnimatedShimmerButtonState();
}

class _AnimatedShimmerButtonState extends State<AnimatedShimmerButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Button Layer
        Positioned.fill(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSecured ? Colors.transparent : widget.strandColor,
              foregroundColor: widget.isSecured ? Colors.greenAccent : Colors.white,
              elevation: widget.isSecured ? 0 : 8,
              shadowColor: widget.strandColor.withValues(alpha: 0.6),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: widget.isSecured ? Colors.greenAccent : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            onPressed: widget.onPressed,
            child: const SizedBox.shrink(), // Content pushed to top of stack
          ),
        ),
        
        // Full Button Shimmer Overlay (Only if unlocked)
        if (!widget.isSecured)
          Positioned.fill(
            child: IgnorePointer( // Don't block button taps
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    // FractionalTranslation moves the container outside the bounds 
                    // on the left, across to the right in a seamless loop.
                    return FractionalTranslation(
                      translation: Offset(-1.5 + (_shimmerController.value * 3.0), 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
        // Text Content Layer (Always stays perfectly centered on top)
        Positioned.fill(
          child: IgnorePointer( // Text doesn't need touch events, the base button handles it
            child: Center(
              child: Text(
                widget.isSecured ? 'PORTAL CLOSED' : 'ENTER PORTAL',
                style: GoogleFonts.inter(
                  color: widget.isSecured ? Colors.greenAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}