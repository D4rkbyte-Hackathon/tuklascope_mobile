import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../../main_navigation.dart';
import 'package:tuklascope_mobile/core/services/health_service.dart';

// Import your custom Gradient Scaffold
import '../../core/widgets/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  // 🚀 ADDED: Optional parameter to force the next destination
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
    // 1. Wait 2 seconds for the splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 🚀 FIXED: If a specific next screen was requested, go there immediately!
    if (widget.nextScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen!),
      );
      return; 
    }

    // 2. Default logic: Check Supabase to see if they are already logged in
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
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