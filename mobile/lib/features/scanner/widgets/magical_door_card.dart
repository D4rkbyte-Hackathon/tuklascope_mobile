import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'animated_shimmer_button.dart';

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

class _MagicalDoorCardState extends State<MagicalDoorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // 🚀 OPTIMIZATION: Only start float animation if initially focused
    if (widget.isFocused) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MagicalDoorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🚀 OPTIMIZATION: Start/Stop the float animation as the user swipes
    if (widget.isFocused && !oldWidget.isFocused) {
      _idleController.repeat(reverse: true);
    } else if (!widget.isFocused && oldWidget.isFocused) {
      _idleController.stop();
      _idleController.value = 0.0; // Reset to ground state
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

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
    final lens = widget.doorData['lens'] ?? 'Unknown';
    final title = widget.doorData['title'] ?? 'Mysterious Path';
    final teaser = widget.doorData['teaser_text'] ?? '';
    const int xp = 50;

    final Color strandColor =
        widget.isSecured ? Colors.greenAccent : _getColorForStrand(lens);
    final IconData icon =
        widget.isSecured ? Icons.verified : _getIconForStrand(lens);

    return AnimatedBuilder(
        animation: _idleController,
        builder: (context, child) {
          // Only calculate float if focused
          final double floatOffset = widget.isFocused
              ? math.sin(_idleController.value * math.pi) * 8
              : 0;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                // 🚀 OPTIMIZATION: Replaced BackdropFilter with a darker semi-transparent gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.80),
                    theme.colorScheme.surface.withValues(alpha: 0.65),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: strandColor.withValues(
                      alpha: widget.isSecured ? 1.0 : 0.6),
                  width: widget.isSecured ? 3 : 1.5,
                ),
                boxShadow: [
                  // 🚀 OPTIMIZATION: Static shadow spread, cheaper to render
                  BoxShadow(
                    color: strandColor.withValues(
                        alpha: widget.isFocused ? 0.25 : 0.05),
                    blurRadius: 25,
                    spreadRadius: widget.isFocused ? 8 : 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
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
                                )),
                            child: Icon(icon, color: strandColor, size: 36),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.isSecured
                                  ? Colors.greenAccent.withValues(alpha: 0.15)
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.isSecured
                                    ? Colors.greenAccent
                                    : theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.isSecured
                                      ? Icons.lock_open
                                      : Icons.auto_awesome,
                                  color: widget.isSecured
                                      ? Colors.greenAccent
                                      : const Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.isSecured ? 'EXTRACTED' : '+$xp XP',
                                  style: GoogleFonts.orbitron(
                                    color: widget.isSecured
                                        ? Colors.greenAccent
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
                            letterSpacing: 3,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: strandColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                              )
                            ]),
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: AnimatedShimmerButton(
                          isSecured: widget.isSecured,
                          isFocused: widget.isFocused, // Pass focus state down!
                          strandColor: strandColor,
                          onPressed: widget.isSecured
                              ? null
                              : widget.onEnterPortal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}