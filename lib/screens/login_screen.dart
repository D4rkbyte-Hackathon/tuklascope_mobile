import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // We will add authentication logic here later!
          },
          child: const Text('Enter Tuklascope'),
        ),
      ),
    );
  }
}
