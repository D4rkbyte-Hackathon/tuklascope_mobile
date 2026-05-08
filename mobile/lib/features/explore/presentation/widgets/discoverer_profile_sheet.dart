//discoverer profile sheet
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart'; // NAVBAR LISTENER

class DiscovererProfileSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  final bool isMe;

  const DiscovererProfileSheet({
    super.key,
    required this.user,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extracting User Data
    final name = user['full_name'] ?? 'Anonymous Explorer';
    final bio = user['bio'] ?? 'This explorer prefers to keep their journey a mystery... for now.';
    final xp = user['total_xp'] ?? 0;
    final level = user['current_level'] ?? 1;
    final streak = user['current_streak'] ?? 0;
    final avatarUrl = user['profile_picture_url'];
    final city = user['city'];
    final country = user['country'];
    final grade = user['education_level'];

    // Dynamic Bottom Padding for NavBar
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final extraBottomPadding = safeBottom + (isNavBarVisible ? 80.0 : 32.0);

    // Determine the user's primary accent color based on rank
    Color accentColor = theme.colorScheme.secondary;
    if (rank == 1) accentColor = Colors.amber;
    else if (rank == 2) accentColor = Colors.blueGrey[300]!;
    else if (rank == 3) accentColor = const Color(0xFFCD7F32); 
    else if (isMe) accentColor = theme.colorScheme.primary;

    String locationText = [city, country].where((e) => e != null && e.isNotEmpty).join(', ');
    if (locationText.isEmpty) locationText = 'Parts Unknown';

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // Close on background tap
      child: Container(
        color: Colors.transparent, // Captures taps outside the sheet
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Push content to bottom
          children: [
            // Gesture catcher for the inside of the sheet so tapping it doesn't close it
            GestureDetector(
              onTap: () {}, 
              child: Stack(
                clipBehavior: Clip.none, // CRITICAL: Allows avatar to break out of its container
                alignment: Alignment.topCenter,
                children: [
                  
                  // The actual Sheet Body (Pushed down by 48 to make room for Avatar)
                  Container(
                    margin: const EdgeInsets.only(top: 48), 
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          // Notice the dynamic bottom padding added here!
                          padding: EdgeInsets.only(top: 64, left: 24, right: 24, bottom: extraBottomPadding),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.85),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            border: Border(
                              top: BorderSide(color: accentColor.withValues(alpha: 0.5), width: 2),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accentColor.withValues(alpha: 0.15),
                                theme.colorScheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // --- PROFILE HEADER ---
                              Text(
                                name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.w900, 
                                  color: theme.colorScheme.onSurface
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fade(duration: 400.ms).slideY(begin: 0.2),

                              const SizedBox(height: 6),

                              // Location & Grade 
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    locationText,
                                    style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                                  ),
                                  if (grade != null && grade.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                    Container(width: 4, height: 4, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.school_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    const SizedBox(width: 4),
                                    Text(
                                      grade,
                                      style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                                    ),
                                  ],
                                ],
                              ).animate().fade(delay: 100.ms).slideY(begin: 0.2),

                              const SizedBox(height: 24),

                              // --- STATS ROW ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatBlock(theme, 'RANK', '#$rank', accentColor),
                                  _buildStatBlock(theme, 'LEVEL', '$level', theme.colorScheme.primary),
                                  _buildStatBlock(theme, 'XP', '$xp', theme.colorScheme.secondary),
                                  _buildStatBlock(theme, 'STREAK', '$streak🔥', Colors.orangeAccent),
                                ],
                              ).animate().fade(delay: 200.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),

                              const SizedBox(height: 28),

                              // --- BADGES SECTION ---
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'FEATURED BADGES',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold, 
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildBadgePlaceholder(theme, accentColor, 0),
                                        const SizedBox(width: 24),
                                        _buildBadgePlaceholder(theme, accentColor, 1),
                                        const SizedBox(width: 24),
                                        _buildBadgePlaceholder(theme, accentColor, 2),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fade(delay: 300.ms).slideY(begin: 0.2),

                              const SizedBox(height: 28),

                              // --- BIO (Left Aligned Fix) ---
                              Container(
                                width: double.infinity, // Forces container to span full width
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(left: BorderSide(color: accentColor, width: 3)),
                                ),
                                child: Text(
                                  '"$bio"',
                                  style: GoogleFonts.inter(
                                    fontStyle: FontStyle.italic, 
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left, // Aligns text to the left boundary
                                ),
                              ).animate().fade(delay: 400.ms).slideX(begin: 0.1),
                              
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- AVATAR FIX ---
                  // Placed at top: 0. Because the sheet has a margin of 48, the avatar sits perfectly half-in/half-out!
                  Positioned(
                    top: 0, 
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null 
                            ? Icon(Icons.person, color: accentColor, size: 40) 
                            : null,
                      ),
                    ).animate().scaleXY(begin: 0.0, curve: Curves.easeOutBack, duration: 600.ms)
                     .shimmer(delay: 600.ms, color: Colors.white54, duration: 1.seconds),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock(ThemeData theme, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10, 
            fontWeight: FontWeight.bold, 
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgePlaceholder(ThemeData theme, Color accent, int index) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.15), 
          width: 2
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline_rounded, 
          size: 20, 
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3) 
        ),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .boxShadow(
      begin: BoxShadow(color: accent.withValues(alpha: 0.0), blurRadius: 0),
      end: BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1),
      duration: 1.5.seconds,
      delay: (index * 300).ms, 
    );
  }
}