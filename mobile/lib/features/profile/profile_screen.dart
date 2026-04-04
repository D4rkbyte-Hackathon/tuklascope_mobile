import 'package:flutter/material.dart';

import '../../core/widgets/gradient_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Profile & Skill Tree')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 5.1: Profile', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => const PathfinderPanel(),
              ),
              child: const Text('Open 5.2: Pathfinder AI Suggestion'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECONDARY SKELETON ---
class PathfinderPanel extends StatelessWidget {
  const PathfinderPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 400,
      child: Column(
        children: [
          const Text('Screen 5.2: Pathfinder AI Suggestions', style: TextStyle(fontSize: 20)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // THIS IS THE RETURN BUTTON
            child: const Text('Close Suggestions'),
          )
        ],
      ),
    );
  }
}