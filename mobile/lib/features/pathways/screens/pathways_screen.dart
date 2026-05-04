import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/gradient_scaffold.dart'; // Adjust path if needed

import '../data/mock_pathways_data.dart';
import '../widgets/header_section.dart';
import '../widgets/project_card.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      }, 
      child: GradientScaffold(
        body: Center(
          child: ListView.builder(
            itemCount: 1 + myProjects.length,
            itemBuilder: (context, index) {
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