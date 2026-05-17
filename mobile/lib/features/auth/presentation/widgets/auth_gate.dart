import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 Added Supabase import
import '../../providers/auth_controller.dart';
import '../../../onboarding/splash_screen.dart';
import '../../../onboarding/compass_questions_screen.dart'; // 🚀 Added Compass import
import '../screens/login_screen.dart';
import '../../../../main_navigation.dart';

// 🚀 NEW: Riverpod provider to check if the user completed the compass
final compassCheckProvider = FutureProvider.family<bool, String>((ref, userId) async {
  try {
    final compassCheck = await Supabase.instance.client
        .from('compass_results')
        .select('user_id')
        .eq('user_id', userId)
        .limit(1);
    return compassCheck.isNotEmpty;
  } catch (e) {
    debugPrint('🚨 Compass Check Error: $e');
    return true; // Fallback to true so we don't trap offline users in an endless loop
  }
});

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
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isCheckingStorage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Splash Screen while checking local storage. 
    // 🚀 Added handlesNavigation: false so it acts ONLY as a loading screen and doesn't fight AuthGate!
    if (_isCheckingStorage) {
      return const SplashScreen(handlesNavigation: false);
    }
    
    // Listen to the master AppUser state stream
    final appUserState = ref.watch(appUserProvider);

    return appUserState.when(
      data: (appUser) {
        if (appUser == null) {
          // No user = Force them to the Login Screen
          return const LoginScreen();
        }
        
        // 🚀 BINGO: User exists. Before we let them in, check the Compass completion state!
        final compassState = ref.watch(compassCheckProvider(appUser.auth.id));
        
        return compassState.when(
          data: (hasCompleted) => hasCompleted 
              ? const MainNavigation() 
              : const CompassQuestionsScreen(), // 🚀 Trap triggered! Force them to finish.
          loading: () => const SplashScreen(handlesNavigation: false),
          error: (err, st) => const MainNavigation(), // Safe fallback
        );
      },
      loading: () => const SplashScreen(handlesNavigation: false),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Authentication Error: $error'))),
    );
  }
}