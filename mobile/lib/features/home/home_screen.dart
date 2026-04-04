import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Needed for ConsumerWidget

// Adjust these imports if your folder structure is slightly different!
import '../auth/providers/auth_provider.dart';
import '../onboarding/splash_screen.dart';

import '../../core/widgets/gradient_scaffold.dart';

// 1. Change StatelessWidget to ConsumerWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 2. Add 'WidgetRef ref' to the build method parameters
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // THE LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              // A. Tell Supabase to kill the session and delete the token
              await ref.read(authServiceProvider).signOut();

              // B. Kick the user back to the Splash Screen
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false, // This completely destroys the navigation history so they can't hit "Back"
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Screen 2.1: Home', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}