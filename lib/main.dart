import 'package:flutter/material.dart';

void main() {
  runApp(const TuklascopeApp());
}

class TuklascopeApp extends StatelessWidget {
  const TuklascopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuklascope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // We will route this to our actual Splash Screen later!
      home: const Scaffold(
        body: Center(child: Text('Tuklascope System Initialization...')),
      ),
    );
  }
}
