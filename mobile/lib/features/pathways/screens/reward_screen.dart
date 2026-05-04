import 'package:flutter/material.dart';
import '../models/project_data.dart';
import '../widgets/stats_block.dart';

class RewardScreen extends StatelessWidget {
  final ProjectData data;

  const RewardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = data.progress == 100;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Image.network(
            data.image,
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: MediaQuery.of(context).size.height * 0.6,
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              child: Icon(Icons.image_not_supported, size: 50, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 6),
                    ),
                    child: Icon(Icons.star_rounded, size: 70, color: isCompleted ? Colors.yellow : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1, shadows: [Shadow(color: Colors.black54, blurRadius: 10)]),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted
                            ? "Congratulations! You've completed the ${data.title} journey."
                            : "You have not completed this task yet. Track your milestones below.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 25),
                      StatsBlock(data: data),
                      const SizedBox(height: 30),
                      Text("Quest Milestones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      ...data.tasks.asMap().entries.map((entry) {
                        final isDone = entry.key < (data.progress / 100 * data.tasks.length).floor();
                        return _buildMilestone(entry.value, isDone, theme);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone(String title, bool isDone, ThemeData theme) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      title: Text(title, style: TextStyle(color: isDone ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
    );
  }
}