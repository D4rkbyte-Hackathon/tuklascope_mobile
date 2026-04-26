import 'package:flutter/material.dart';

Route createAnimatedAuthRoute(Widget page, {bool slideLeft = true}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = Offset(slideLeft ? 1.0 : -1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutExpo;
      
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}