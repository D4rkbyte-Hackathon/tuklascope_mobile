import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart'; // We are importing your custom screen here!

void main() {
  // ProviderScope is the Riverpod "cloud" that holds our gamified state
  runApp(const ProviderScope(child: TuklascopeApp()));
}

class TuklascopeApp extends StatelessWidget {
  const TuklascopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuklascope',
      debugShowCheckedModeBanner:
          false, // This hides that little red "DEBUG" banner in the corner!
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home:
          const SplashScreen(), // Boom. The Splash Screen is now the starting point.
    );
  }
}
