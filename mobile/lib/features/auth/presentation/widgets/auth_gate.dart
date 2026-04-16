import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_controller.dart';
import '../../../onboarding/splash_screen.dart';
import '../screens/login_screen.dart';
import '../../../../main_navigation.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the master AppUser state stream we built earlier
    final appUserState = ref.watch(appUserProvider);

    return appUserState.when(
      data: (appUser) {
        if (appUser == null) {
          // No user = Force them to the Login Screen
          return const LoginScreen();
        }
        // User exists = Allow them into the Main App Navigation
        return const MainNavigation();
      },
      loading: () =>
          const SplashScreen(), // Show your beautiful logo while loading
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Authentication Error: $error'))),
    );
  }
}
