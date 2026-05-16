import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassConceptCard extends StatelessWidget {
  final String title;
  final String content;
  final String? badgeText;

  const GlassConceptCard({
    super.key,
    required this.title,
    required this.content,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.travel_explore_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ).animate().fade().slideX(begin: -0.1),
        
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.05),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(4),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    border: Border(left: BorderSide(color: accentColor, width: 3)),
                  ),
                  child: Text(
                    badgeText!.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public_rounded, color: accentColor, size: 22)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1.seconds),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fade().slideY(begin: 0.1),
      ],
    );
  }
}