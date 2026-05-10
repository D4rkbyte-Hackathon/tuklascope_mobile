import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart'; // 🚀 IMPORTED NAV SCOPE
import '../data/mock_pathways_data.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 🚀 Added NavScope logic to detect the bottom nav bar
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BADGE CASE',
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 🚀 THE OPTIMIZED SLIVER GRID
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // THE GRID OF BADGES
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85, 
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final project = myProjects[index];
                          final isUnlocked = index % 3 != 1; 

                          return RepaintBoundary(
                            child: _buildBadgeHex(context, project.title, project.badge, isUnlocked, index),
                          );
                        },
                        childCount: myProjects.length,
                      ),
                    ),
                  ),
                  
                  // 🚀 DYNAMIC BOTTOM PADDING BLOCK
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuint,
                      height: (isNavBarVisible ? 60.0 : 10.0) + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeHex(BuildContext context, String title, String badgePath, bool isUnlocked, int index) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked 
            ? primaryColor.withValues(alpha: 0.4) 
            : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: -5)
        ] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.5),
                            primaryColor.withValues(alpha: 0.0), 
                          ],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .fade(begin: 0.4, end: 1.0, duration: 2.seconds), 
                  
                  // The Badge Artwork
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      isUnlocked 
                        ? [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0] 
                        : [0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0.2126,0.7152,0.0722,0,0, 0,0,0,0.4,0],
                    ),
                    child: Image.asset(badgePath, fit: BoxFit.contain)
                      .animate()
                      .scaleXY(begin: 0.5, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack, delay: (50 * index).ms),
                  ),
                ],
              ),
            ),
          ),
          
          // TITLE TEXT
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Text(
              isUnlocked ? title : '???',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isUnlocked 
                  ? theme.colorScheme.onSurface 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}