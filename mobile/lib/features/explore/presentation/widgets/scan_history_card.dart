import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ScanHistoryCard extends StatefulWidget {
  final String scanId;
  final String title;
  final String subtitle;
  final String tag;
  final String? imageUrl;
  final int? xpAwarded;
  final bool isFavorite;
  final Color accent;
  final VoidCallback? onTap;
  final Future<void> Function(bool isFavorite)? onFavoriteChanged;

  const ScanHistoryCard({
    super.key,
    required this.scanId,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.imageUrl,
    this.xpAwarded,
    this.isFavorite = false,
    required this.accent,
    this.onTap,
    this.onFavoriteChanged,
  });

  @override
  State<ScanHistoryCard> createState() => _ScanHistoryCardState();
}

class _ScanHistoryCardState extends State<ScanHistoryCard> {
  bool _isPressed = false;
  bool _isTogglingFavorite = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glowColor = widget.accent;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: AspectRatio(
        aspectRatio: 0.68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTap?.call();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.2),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface.withValues(alpha: isDark ? 0.8 : 0.95),
                        theme.colorScheme.surface.withValues(alpha: isDark ? 0.6 : 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: glowColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TOP HALF: Holographic Image
                      Expanded(
                        flex: 5,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                                ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                                : Container(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    child: Icon(Icons.science, color: glowColor.withValues(alpha: 0.5), size: 50),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),

                            // Card Tag Badge
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  widget.tag.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // BOTTOM HALF: Stats & Data
                      Expanded(
                        flex: 5, // 👈 Gave a little more flex to fit the new skill box comfortably
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.timeline, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Discovered: ${widget.subtitle}",
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // XP Reward Bar
                              if (widget.xpAwarded != null && widget.xpAwarded! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.4)),
                                    boxShadow: [
                                      BoxShadow(color: theme.colorScheme.tertiary.withValues(alpha: 0.3), blurRadius: 10),
                                    ]
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.stars, color: theme.colorScheme.tertiary, size: 16)
                                        .animate(onPlay: (c) => c.repeat())
                                        .shimmer(duration: 1500.ms, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Text(
                                        "+${widget.xpAwarded} XP",
                                        style: GoogleFonts.orbitron(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.tertiary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scaleXY(begin: 1.0, end: 1.02, duration: 2.seconds, curve: Curves.easeInOut),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _buildFavoriteButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    final isFavorite = widget.isFavorite;

    return GestureDetector(
      onTap: _isTogglingFavorite ? null : _handleFavoriteTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: isFavorite ? Colors.amber : Colors.white.withValues(alpha: 0.2),
          ),
          boxShadow: isFavorite
              ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 10)]
              : [],
        ),
        child: _isTogglingFavorite
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
              )
            : Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber : Colors.white,
                size: 20,
              ).animate(target: isFavorite ? 1 : 0)
               .scaleXY(begin: 1.0, end: 1.2, duration: 200.ms, curve: Curves.easeOutBack)
               .then()
               .scaleXY(end: 1.0),
      ),
    );
  }

  Future<void> _handleFavoriteTap() async {
    if (widget.onFavoriteChanged == null || _isTogglingFavorite) return;

    setState(() => _isTogglingFavorite = true);
    try {
      await widget.onFavoriteChanged!(!widget.isFavorite);
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }
}