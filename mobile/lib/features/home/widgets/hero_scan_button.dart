import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/navigation/main_nav_scope.dart';

class HeroScanButton extends StatelessWidget {
  const HeroScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: GestureDetector(
        onTap: () => MainNavScope.maybeOf(context)?.goToTab(1),
        child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.document_scanner_rounded, size: 70, color: Colors.white),
              SizedBox(height: 12),
              Text(
                "TAP TO SCAN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
    );
  }
}