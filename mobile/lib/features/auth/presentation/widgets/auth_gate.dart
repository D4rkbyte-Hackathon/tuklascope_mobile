import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_controller.dart';
import '../../../onboarding/splash_screen.dart';
import '../screens/login_screen.dart';
import '../../../../main_navigation.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isCheckingStorage = true;

  @override
  void initState() {
    super.initState();
    _waitForSupabaseSession();
  }

  // Wait for Supabase to initialize and check stored session
  Future<void> _waitForSupabaseSession() async {
    // Give auth state a moment to restore from secure storage
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isCheckingStorage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show your beautiful Splash Screen while checking local storage
    if (_isCheckingStorage) {
      return const SplashScreen();
    }
    
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