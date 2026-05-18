import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_controller.dart';
import '../../providers/auth_flow_providers.dart';
import '../../../onboarding/splash_screen.dart';
import '../../../onboarding/compass_questions_screen.dart';
import '../screens/login_screen.dart';
import '../screens/social_login_profile_screen.dart';
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
        
        final profileState =
            ref.watch(profileCompletionCheckProvider(appUser.auth.id));

        return profileState.when(
          data: (hasCompletedProfile) {
            if (!hasCompletedProfile) {
              final metadata = appUser.auth.userMetadata;
              final displayName = metadata?['full_name'] as String? ??
                  metadata?['name'] as String? ??
                  appUser.profile.fullName;

              return SocialLoginProfileScreen(
                initialName: displayName,
                userEmail: appUser.auth.email ?? appUser.profile.email,
              );
            }

            final compassState =
                ref.watch(compassCheckProvider(appUser.auth.id));

            return compassState.when(
              data: (hasCompletedCompass) => hasCompletedCompass
                  ? const MainNavigation()
                  : const CompassQuestionsScreen(),
              loading: () => const SplashScreen(handlesNavigation: false),
              error: (err, st) => const MainNavigation(),
            );
          },
          loading: () => const SplashScreen(handlesNavigation: false),
          error: (err, st) => const MainNavigation(),
        );
      },
      loading: () => const SplashScreen(handlesNavigation: false),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Authentication Error: $error'))),
    );
  }
}