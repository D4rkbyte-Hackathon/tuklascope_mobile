import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/navigation/main_nav_scope.dart';

class HeroScanButton extends StatelessWidget {
  const HeroScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 🚀 Hardcoding striking Orange/Blue sci-fi palette
    const neonOrange = Color(0xFFFF7A00);
    const neonBlue = Color(0xFF00E5FF);
    const deepBlue = Color(0xFF0D3B66);

    return Center(
      // Expanded canvas to comfortably fit 4 pointers
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
                    // Orange Sonar Ripples
                    _buildRipple(neonOrange, 0),
                    _buildRipple(neonOrange, 1200),

                    // Blue Radar Sweep Ring
                    Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            neonBlue.withOpacity(0.0),
                            neonBlue.withOpacity(0.8),
                            neonBlue.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),

                    // Core Mask
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface, 
                      ),
                    ),

                    // The Core Gradient Sphere
                    Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            neonBlue,
                            deepBlue, 
                          ],
                          stops: [0.3, 1.0],
                        ),
                        boxShadow: [
                          // Inner Blue Glow
                          BoxShadow(color: neonBlue.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
                          // Outer Orange Ambient Glow
                          BoxShadow(color: neonOrange.withOpacity(0.2), blurRadius: 60, spreadRadius: -10),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.document_scanner_outlined, size: 42, color: Colors.white)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(begin: 0.9, end: 1.1, duration: 1.seconds)
                              .shimmer(duration: 2.seconds, color: neonOrange),
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
                              color: neonOrange,
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
            // 2. 4-CORNER GAMIFIED POINTERS
            // ==========================================
            
            // Top-Left (Blue)
            Positioned(
              top: 10,
              left: 10,
              child: const _FloatingPointer(
                title: "NEW QUEST",
                subtitle: "Scan to begin\nyour journey",
                icon: Icons.south_east_rounded, 
                color: neonBlue,
                isTop: true,
                isLeft: true,
                delayMs: 0,
                durationMs: 1800, // Unique pace
              ),
            ),

            // Top-Right (Orange)
            Positioned(
              top: 10,
              right: 10,
              child: const _FloatingPointer(
                title: "ANALYSIS",
                subtitle: "Identify items\ninstantly",
                icon: Icons.south_west_rounded, 
                color: neonOrange,
                isTop: true,
                isLeft: false,
                delayMs: 700,
                durationMs: 2200, // Unique pace
              ),
            ),

            // Bottom-Left (Orange)
            Positioned(
              bottom: 10,
              left: 10,
              child: const _FloatingPointer(
                title: "TUTORIAL",
                subtitle: "Learn about\nthe world",
                icon: Icons.north_east_rounded, 
                color: neonOrange,
                isTop: false,
                isLeft: true,
                delayMs: 300,
                durationMs: 1600, // Unique pace
              ),
            ),

            // Bottom-Right (Blue)
            Positioned(
              bottom: 10,
              right: 10,
              child: const _FloatingPointer(
                title: "DISCOVERY",
                subtitle: "Unlock hidden\nartifacts",
                icon: Icons.north_west_rounded, 
                color: neonBlue,
                isTop: false,
                isLeft: false,
                delayMs: 1100,
                durationMs: 2000, // Unique pace
              ),
            ),

          ],
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

// ==========================================================
// 🚀 THE FLOATING HOLOGRAPHIC POINTER BOX
// ==========================================================
class _FloatingPointer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isTop;
  final bool isLeft;
  final int delayMs;
  final int durationMs;

  const _FloatingPointer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isTop,
    required this.isLeft,
    required this.delayMs,
    required this.durationMs,
  });

  @override
  Widget build(BuildContext context) {
    final pointerLayout = Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arrow hangs ABOVE the text if it's on the bottom
        if (!isTop) _buildBouncingIcon(),
        
        // Holographic Text Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), 
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            // The border radius points toward the center by making the closest corner sharp (2)
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
        
        // Arrow hangs BELOW the text if it's on the top
        if (isTop) _buildBouncingIcon(),
      ],
    );

    // Apply the floating hover effect using unique randomized paces
    return pointerLayout
        .animate(onPlay: (c) => c.repeat(reverse: true), delay: delayMs.ms)
        .slideY(begin: -0.04, end: 0.04, duration: durationMs.ms, curve: Curves.easeInOutSine)
        .fadeIn(duration: 800.ms);
  }

  // Animates the arrow pointing towards the core
  Widget _buildBouncingIcon() {
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 16 : 0, 
        right: !isLeft ? 16 : 0,
        top: isTop ? 4 : 0,
        bottom: !isTop ? 4 : 0,
      ),
      child: Icon(icon, color: color, size: 24)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.9, end: 1.2, duration: 600.ms, curve: Curves.easeInOut)
        .shimmer(duration: 1.seconds, color: Colors.white),
    );
  }
}