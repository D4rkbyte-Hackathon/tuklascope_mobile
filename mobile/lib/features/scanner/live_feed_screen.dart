import 'package:flutter/material.dart';

class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Feed')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 3.1: Live Feed', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),

            // Button for 3.2 (MODAL)
            ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => const ScanningModal(),
              ),
              child: const Text('Open 3.2: Scanning / Analyzing Modal'),
            ),

            // Button for 3.3 (FULL SCREEN)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeaserDoorsScreen()),
              ),
              child: const Text('Open 3.3: Teaser Doors'),
            ),

            // Button for 3.4 (FULL SCREEN)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscoveryCardsScreen()),
              ),
              child: const Text('Open 3.4: Discovery Cards'),
            ),

            // Button for 3.5 (MODAL)
            ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Allows the panel to be taller
                builder: (context) => const TuklasTutorPanel(),
              ),
              child: const Text('Open 3.5: TuklasTutor Chat Panel'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECONDARY SKELETONS FOR LIVE FEED ---

class ScanningModal extends StatelessWidget {
  const ScanningModal({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300, // Half screen height
      child: Column(
        children: [
          const Text('Screen 3.2: Scanning / Analyzing...', style: TextStyle(fontSize: 20)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // THIS IS THE RETURN BUTTON
            child: const Text('Close Modal'),
          )
        ],
      ),
    );
  }
}

class TeaserDoorsScreen extends StatelessWidget {
  const TeaserDoorsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teaser Doors')), // Free Back Button!
      body: const Center(child: Text('Screen 3.3: Teaser Doors')),
    );
  }
}

class DiscoveryCardsScreen extends StatelessWidget {
  const DiscoveryCardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery Cards')), // Free Back Button!
      body: const Center(child: Text('Screen 3.4: Discovery Cards')),
    );
  }
}

class TuklasTutorPanel extends StatelessWidget {
  const TuklasTutorPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
      child: Column(
        children: [
          const Text('Screen 3.5: TuklasTutor Chat', style: TextStyle(fontSize: 20)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // THIS IS THE RETURN BUTTON
            child: const Text('Close Chat'),
          )
        ],
      ),
    );
  }
}