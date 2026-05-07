import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraTopBar extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onToggleFlash;

  const CameraTopBar({
    super.key,
    required this.isFlashOn,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.radar, color: theme.colorScheme.primary, size: 14),
                const SizedBox(width: 8),
                Text(
                  'SUBJECT TRACKING',
                  style: GoogleFonts.orbitron(
                    color: theme.colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? theme.colorScheme.secondary : Colors.white70,
            ),
            onPressed: onToggleFlash,
          ),
        ],
      ),
    );
  }
}