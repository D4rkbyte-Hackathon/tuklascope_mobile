import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../../main_navigation.dart';
import 'package:tuklascope_mobile/core/services/health_service.dart';

import '../../core/widgets/gradient_scaffold.dart';
import 'compass_questions_screen.dart'; // 🚀 IMPORTED Compass Screen

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen; 
  
  const SplashScreen({super.key, this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    HealthService.pingBackend();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // 1. Wait for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. If a specific next screen was requested (e.g. fresh sign up flow)
    if (widget.nextScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen!),
      );
      return; 
    }

    // 3. Check Supabase to see if they are already logged in
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      
      // 🚀 FIXED: Mandatory Compass Edge-case check!
      try {
        // Ping database to see if this user has compass results
        final compassCheck = await Supabase.instance.client
            .from('compass_results')
            .select('id')
            .eq('user_id', session.user.id)
            .limit(1);

        if (compassCheck.isEmpty) {
          // If empty, they quit the app before finishing! Force them back to the compass.
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()),
          );
          return;
        }
      } catch (e) {
        debugPrint('🚨 COMPASS CHECK ERROR: $e');
        if (mounted) {
           // Show a warning banner so we know the DB is angry, instead of failing silently
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Database Error: $e'), backgroundColor: Colors.red),
           );
        }
      }

      // If they passed the check, send them to Home!
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
      
    } else {
      // Not logged in -> Send to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', 
          width: 500, 
          height: 500,
          fit: BoxFit.contain, 
        ),
      ),
    );
  }
}