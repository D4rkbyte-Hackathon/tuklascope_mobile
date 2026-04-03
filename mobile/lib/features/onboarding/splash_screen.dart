import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../../main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // 1. Wait 2 seconds for the splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // 2. Check Supabase to see if they are already logged in from a previous session
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // If returning user, skip login and compass -> Go straight to Main Navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()), //add const later eg const MainNavigation (mas smooth daw ingon gemini)
      );
    } else {
      // If new or logged out -> Go to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.deepPurple, 
      body: Center(
        child: Text(
          'Tuklascope\n(Logo Here)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}