import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';

class TuklasTutorScreen extends StatelessWidget {
  const TuklasTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'TuklasTutor',
          style: TextStyle(color: Color(0xFF0B3C6A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B3C6A)),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3C6A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Color(0xFF0B3C6A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TuklasTutor Chat Interface\n(Coming Soon)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}