import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              width: isUnlocked ? 35 : 20,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.greenAccent
                    : Colors.white.withValues(alpha: 0.2),
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