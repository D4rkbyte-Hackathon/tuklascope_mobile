import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/gradient_scaffold.dart'; // Adjust path if needed
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import '../data/mock_pathways_data.dart';
import '../widgets/header_section.dart';
import '../widgets/project_card.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      }, 
      child: GradientScaffold(
        body: Center(
          child: ListView.builder(
            itemCount: 2 + myProjects.length,
            itemBuilder: (context, index) {

              if (index == 1 + myProjects.length) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuint,
                  height: (isNavBarVisible ? 100.0 : 20.0) + MediaQuery.paddingOf(context).bottom,
                );
              }
              
              Widget item;
              
              if (index == 0) {
                // Passed the variables cleanly instead of reading globals
                item = const HeaderSection(
                  activePathways: mockActivePathways,
                  averageProgress: mockAverageProgress,
                  totalPoints: mockTotalPoints,
                ); 
              } else {
                item = ProjectCard(data: myProjects[index - 1]);
              }
              
              return item
                  .animate()
                  .fade(duration: 600.ms, delay: (100 * index).ms)
                  .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
            },
          ),
        ),
      ),
    );
  }
}