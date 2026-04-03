import 'package:flutter/material.dart';
import '../../../main_navigation.dart';

class CompassResultsScreen extends StatelessWidget {
  const CompassResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        // Optional: Remove the back button if you don't want them retaking it immediately
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 1.3.2: Compass Results', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // FINAL STEP: Push replacement to the Home Screen / Bottom Tabs
                // This destroys the onboarding flow stack so they can't go back.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                );
              },
              child: const Text('Enter Tuklascope'),
            ),
          ],
        ),
      ),
    );
  }
}