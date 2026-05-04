import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS
import '../../../core/navigation/main_nav_scope.dart';

class HeroScanButton extends StatelessWidget {
  const HeroScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: GestureDetector(
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(1),
        child: SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 4. Outer Expanding Ripple
              Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.5), width: 2),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
               .scaleXY(begin: 0.8, end: 1.2, duration: 2.seconds, curve: Curves.easeOut)
               .fadeOut(duration: 2.seconds, curve: Curves.easeOut),

              // Middle Glowing Ring
              Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 4),
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
              ),

              // Core Sci-Fi Button
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF0D3B66)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.6),
                      blurRadius: 30, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.document_scanner_rounded, size: 50, color: Colors.white)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .slideY(begin: -0.1, end: 0.1, duration: 1.seconds),
                    const SizedBox(height: 8),
                    Text(
                      "SCAN",
                      style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }
}