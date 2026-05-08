import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanHistoryCard extends StatelessWidget {
  const ScanHistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.accent,
    this.xpAwarded, // 👈 NEW: Added XP
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final String? imageUrl;
  final Color accent;
  final int? xpAwarded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: isDark ? 0 : 4, // Slightly higher elevation for better depth
        shadowColor: theme.shadowColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24), // Smoother, modern curves
        color: theme.colorScheme.surface,
        child: Container(
          decoration: isDark
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ IMAGE HEADER
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 180, // Slightly taller for better preview
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl!.isNotEmpty)
                        Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                        )
                      else
                        _buildPlaceholder(theme),
                      
                      // Gradient overlay for better text contrast if we decide to overlay text later
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                      
                      // 🏷️ LENS BADGE
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 📝 CONTENT SECTION
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.onSurface
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // 📅 DATE & 💎 XP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 6),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 13, 
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              ),
                            ),
                          ],
                        ),
                        if (xpAwarded != null && xpAwarded! > 0)
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '+$xpAwarded XP',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Icon(
      Icons.camera_alt_outlined, 
      size: 48, 
      color: theme.colorScheme.onSurface.withValues(alpha: 0.2)
    );
  }
}