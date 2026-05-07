import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/navigation/main_nav_scope.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final int xp;
  final String? avatarUrl;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.xp,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Clickable Profile Icon
        GestureDetector(
          onTap: () => MainNavScope.maybeOf(context)?.goToTab(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null 
                  ? Icon(Icons.person, size: 32, color: theme.colorScheme.primary) 
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.inter( 
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userName,
                style: GoogleFonts.montserrat( 
                  fontSize: 22, // Increased size for title emphasis
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  height: 1.1, // Tighter line height
                ),
              ),
            ],
          ),
        ),
        // XP Badge with Glow and Shimmer Animation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.tertiary.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ]
          ),
          child: Row(
            children: [
              Icon(Icons.stars_rounded, color: theme.colorScheme.tertiary, size: 20),
              const SizedBox(width: 6),
              Text(
                "$xp XP",
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold, 
                  color: theme.colorScheme.tertiary
                ), 
              ),
            ],
          ),
        )
        // 🚀 Looping shimmer effect to make the XP badge shine
        .animate(onPlay: (controller) => controller.repeat(reverse: false))
        .shimmer(duration: 2000.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.6)),
      ].animate(interval: 50.ms).fade().slideX(begin: -0.1),
    );
  }
}