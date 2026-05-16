import 'dart:ui'; // 🚀 Required for BackdropFilter and ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/navigation/main_nav_scope.dart';

class HeroScanButton extends StatelessWidget {
  const HeroScanButton({super.key});

  // 🚀 Updated to a Central Dialog instead of a Bottom Sheet
  void _showTutorialModal(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), // Dims the background slightly
      builder: (context) => _TutorialDialog(theme: theme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final colorPrimary = theme.colorScheme.primary; 
    final colorSecondary = theme.colorScheme.tertiary; 
    final deepBackground = theme.colorScheme.surface; 

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 380, 
            height: 380,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ==========================================
                // 1. THE CORE BUTTON 
                // ==========================================
                GestureDetector(
                  onTap: () => MainNavScope.maybeOf(context)?.goToTab(1),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRipple(colorSecondary, 0),
                        _buildRipple(colorSecondary, 1200),

                        Container(
                          width: 220, height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                colorPrimary.withOpacity(0.0),
                                colorPrimary.withOpacity(0.8),
                                colorPrimary.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),

                        Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: deepBackground, 
                          ),
                        ),

                        Container(
                          width: 160, height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [colorPrimary, deepBackground],
                              stops: const [0.3, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(color: colorPrimary.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
                              BoxShadow(color: colorSecondary.withOpacity(0.2), blurRadius: 60, spreadRadius: -10),
                            ],
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.document_scanner_outlined, size: 42, color: Colors.white)
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scaleXY(begin: 0.9, end: 1.1, duration: 1.seconds)
                                  .shimmer(duration: 2.seconds, color: colorSecondary),
                              const SizedBox(height: 4),
                              Text(
                                "SCAN",
                                style: GoogleFonts.orbitron( 
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                "AI READY",
                                style: GoogleFonts.inter( 
                                  color: colorSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.97, end: 1.03, duration: 2.seconds, curve: Curves.easeInOutSine),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // 2. TAPPABLE GAMIFIED POINTERS
                // ==========================================
                Positioned(
                  top: 10, left: 10,
                  child: _FloatingPointer(
                    title: "NEW QUEST", subtitle: "Scan to begin\nyour journey",
                    icon: Icons.south_east_rounded, color: colorPrimary,
                    isTop: true, isLeft: true, delayMs: 0, durationMs: 1800,
                    onTap: () => MainNavScope.maybeOf(context)?.goToTab(2), 
                  ),
                ),

                Positioned(
                  top: 10, right: 10,
                  child: _FloatingPointer(
                    title: "ANALYSIS", subtitle: "Identify items\ninstantly",
                    icon: Icons.south_west_rounded, color: colorSecondary,
                    isTop: true, isLeft: false, delayMs: 700, durationMs: 2200,
                    onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
                  ),
                ),

                Positioned(
                  bottom: 10, left: 10,
                  child: _FloatingPointer(
                    title: "TUTORIAL", subtitle: "Learn about\nthe world",
                    icon: Icons.north_east_rounded, color: colorSecondary,
                    isTop: false, isLeft: true, delayMs: 300, durationMs: 1600,
                    onTap: () => _showTutorialModal(context, theme), 
                  ),
                ),

                Positioned(
                  bottom: 10, right: 10,
                  child: _FloatingPointer(
                    title: "DISCOVERY", subtitle: "Unlock hidden\nartifacts",
                    icon: Icons.north_west_rounded, color: colorPrimary,
                    isTop: false, isLeft: false, delayMs: 1100, durationMs: 2000,
                    onTap: () => MainNavScope.maybeOf(context)?.goToTab(4), 
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildRipple(Color color, int delayMs) {
    return Container(
      width: 260, height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.6), width: 2),
      ),
    )
    .animate(onPlay: (c) => c.repeat(), delay: delayMs.ms)
    .scaleXY(begin: 0.6, end: 1.15, duration: 2400.ms, curve: Curves.easeOut)
    .fadeOut(duration: 2400.ms, curve: Curves.easeOut);
  }
}

class _FloatingPointer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isTop;
  final bool isLeft;
  final int delayMs;
  final int durationMs;
  final VoidCallback onTap; 

  const _FloatingPointer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isTop,
    required this.isLeft,
    required this.delayMs,
    required this.durationMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pointerLayout = Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isTop) _buildBouncingIcon(),
        
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), 
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular((!isTop && !isLeft) ? 2 : 12),
                topRight: Radius.circular((!isTop && isLeft) ? 2 : 12),
                bottomLeft: Radius.circular((isTop && !isLeft) ? 2 : 12),
                bottomRight: Radius.circular((isTop && isLeft) ? 2 : 12),
              ),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, spreadRadius: 2),
              ]
            ),
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.orbitron(
                    color: color, 
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  )
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, 
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9), 
                    fontSize: 10, 
                    fontWeight: FontWeight.w600,
                    height: 1.2
                  ), 
                  textAlign: isLeft ? TextAlign.left : TextAlign.right
                ),
              ]
            ),
          ),
        ),
        
        if (isTop) _buildBouncingIcon(),
      ],
    );

    return pointerLayout
        .animate(onPlay: (c) => c.repeat(reverse: true), delay: delayMs.ms)
        .slideY(begin: -0.04, end: 0.04, duration: durationMs.ms, curve: Curves.easeInOutSine)
        .fadeIn(duration: 800.ms);
  }

  Widget _buildBouncingIcon() {
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 16 : 0, right: !isLeft ? 16 : 0,
        top: isTop ? 4 : 0, bottom: !isTop ? 4 : 0,
      ),
      child: Icon(icon, color: color, size: 24)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.9, end: 1.2, duration: 600.ms, curve: Curves.easeInOut)
        .shimmer(duration: 1.seconds, color: Colors.white),
    );
  }
}

// ==========================================================
// 🚀 THE NEW CENTRAL GLASSMORPHISM TUTORIAL DIALOG
// ==========================================================
class _TutorialDialog extends StatelessWidget {
  final ThemeData theme;
  const _TutorialDialog({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent, // Required to let the background blur show through
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🚀 The Glass Blur
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.75), // Semi-transparent surface
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: -5)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Hugs content perfectly in the center
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "GET STARTED", 
                          style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, size: 20, color: theme.colorScheme.onSurface),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStep(Icons.camera_alt_rounded, "1. Scan the World", "Tap the big core button to open your AI scanner.", theme),
                    _buildStep(Icons.auto_awesome, "2. Discover Artifacts", "Scan objects around you to identify them and earn XP.", theme),
                    _buildStep(Icons.account_tree_rounded, "3. Level Up Skills", "Different objects give you STEM, HUMSS, ABM, or TVL points.", theme),
                    _buildStep(Icons.emoji_events_rounded, "4. Climb the Ranks", "Complete pathways and compete on the global leaderboard!", theme),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.85), // Slight transparency to match glass theme
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("GOT IT, LET'S GO!", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack, duration: 400.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _buildStep(IconData icon, String title, String desc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7), height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }
}