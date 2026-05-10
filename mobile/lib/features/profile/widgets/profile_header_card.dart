import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ThemeData theme;
  final String fullName, educationLevel, location;
  final int streak;
  final String? profilePictureUrl;
  final VoidCallback onEditPressed;

  const ProfileHeaderCard({
    super.key,
    required this.theme,
    required this.fullName,
    required this.educationLevel,
    required this.location,
    required this.streak,
    this.profilePictureUrl,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    // --- Dynamic Streak Logic ---
    Color streakColor;
    IconData streakIcon;
    String streakLabel;

    if (streak >= 7) {
      streakColor = const Color(0xFFFF512F); // Intense Fire Orange
      streakIcon = Icons.local_fire_department_rounded;
      streakLabel = '$streak Day Streak!';
    } else if (streak >= 3) {
      streakColor = const Color(0xFFF09819); // Warm Amber
      streakIcon = Icons.whatshot_rounded;
      streakLabel = '$streak Days';
    } else {
      streakColor = theme.colorScheme.onSurface.withValues(alpha: 0.5); // Greyish
      streakIcon = Icons.local_fire_department_outlined;
      streakLabel = '$streak Days';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with a subtle glow effect
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                  backgroundImage: profilePictureUrl?.isNotEmpty == true
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl?.isEmpty ?? true
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.isNotEmpty
                          ? '$educationLevel • $location'
                          : educationLevel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // --- Upgraded Dynamic Streak Pill ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: streakColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: streakColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(streakIcon, size: 16, color: streakColor),
                          const SizedBox(width: 6),
                          Text(
                            streakLabel,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: streakColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    // Continuous Shimmer Animation for the pop!
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(
                      duration: 2.seconds, 
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Text(
                'Edit Profile →',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}