import 'package:flutter/material.dart';
import 'compass_results_screen.dart';

class CompassQuestionsScreen extends StatelessWidget {
  const CompassQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Compass')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 1.3.1: The Compass Questions', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Moving forward to the Results screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompassResultsScreen()),
                );
              },
              child: const Text('Finish Assessment'),
            ),
          ],
        ),
      ),
    );
  }
}