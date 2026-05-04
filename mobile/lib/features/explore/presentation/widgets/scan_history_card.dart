//scan history card
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
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final String? imageUrl;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: isDark ? 0 : 2,
        shadowColor: theme.shadowColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        child: Container(
        decoration: isDark
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                height: 168,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.photo_outlined, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.2));
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: theme.colorScheme.secondary,
                            ),
                          );
                        },
                      )
                    : Icon(Icons.photo_outlined, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tag.toUpperCase(),
                    style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: accent),
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
}