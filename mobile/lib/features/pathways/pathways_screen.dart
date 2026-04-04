import 'package:flutter/material.dart';

import '../../core/widgets/gradient_scaffold.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Learning Pathways')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 4.1: Pathways', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardScreen()),
              ),
              child: const Text('Open 4.2: Action Success / Reward'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECONDARY SKELETON ---
class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Reward Unlocked!')), // Free Back Button!
      body: const Center(child: Text('Screen 4.2: Action Success / Reward UI')),
    );
  }
}