// mobile/lib/features/pathways/widgets/pathway_quest_modals.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pathway_models.dart';

Future<void> showEnrollmentSuccessModal(
  BuildContext context, {
  required Pathway pathway,
}) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.85 : 0.95,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ENROLLED!',
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pathway.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your quest is live. Complete milestones by scanning the world to earn points and progress.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        "LET'S GO",
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(
            begin: const Offset(0.9, 0.9),
            duration: 320.ms,
            curve: Curves.easeOutBack,
          ).fade();
    },
  );
}
