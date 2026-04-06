import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../../main_navigation.dart';

// 1. Import your custom Gradient Scaffold
import '../../core/widgets/gradient_scaffold.dart';

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

    // 2. Check Supabase to see if they are already logged in
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        // Added the const here!
        MaterialPageRoute(builder: (context) => const MainNavigation()), 
      );
    } else {
      Navigator.pushReplacement(
        context,
        // Added the const here!
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Swap the basic Scaffold for your beautiful GradientScaffold
    return GradientScaffold(
      body: Center(
        // 4. Swap the Text for your actual image!
        child: Image.asset(
          'assets/images/logo.png', // Change 'logo.png' if your file is named something else!
          width: 500, // Adjust these numbers to make your logo bigger or smaller
          height: 500,
          fit: BoxFit.contain, // Ensures the logo scales cleanly
        ),
      ),
    );
  }
}