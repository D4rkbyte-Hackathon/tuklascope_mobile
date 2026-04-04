import 'package:flutter/material.dart';

import '../../core/widgets/gradient_scaffold.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Explore / Archives')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 6.1: Explore', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardsScreen()),
              ),
              child: const Text('Open 6.2: Leaderboards'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECONDARY SKELETON ---
class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Leaderboards')), // Free Back Button!
      body: const Center(child: Text('Screen 6.2: Leaderboards')),
    );
  }
}