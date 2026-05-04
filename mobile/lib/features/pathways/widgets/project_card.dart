import 'package:flutter/material.dart';
import '../models/project_data.dart';
import '../utils/pathway_utils.dart';
import '../screens/reward_screen.dart';

class ProjectCard extends StatelessWidget {
  final ProjectData data;

  const ProjectCard({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), width: 1),
      ),
      elevation: theme.brightness == Brightness.dark ? 0 : 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RewardScreen(data: data),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data.image,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.difficulty,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "${data.points} Points",
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Progress:", style: TextStyle(color: theme.colorScheme.onSurface)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${data.progress}",
                          textAlign: TextAlign.end,
                          style: TextStyle(fontWeight: FontWeight.bold, color: getProgressColor(data.progress)),
                        ),
                      ),
                      Text("% Completed", style: TextStyle(color: getProgressColor(data.progress))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}