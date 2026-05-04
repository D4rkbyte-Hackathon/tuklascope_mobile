import 'package:flutter/material.dart';
import '../models/project_data.dart';
import '../utils/pathway_utils.dart';

class StatsBlock extends StatelessWidget {
  final ProjectData data;
  
  const StatsBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text( 
                    data.progress == 100 ? "Completion Date" : "Current Progress", 
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))
                  ),
                  Text(
                    data.progress == 100 ? "December 13, 2025" : "${data.progress}% Done",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: getProgressColor(data.progress)),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            Expanded(
              child: Column(
                children: [
                  Text("Points", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  Text("${data.points}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}