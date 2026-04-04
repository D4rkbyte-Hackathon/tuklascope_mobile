import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar; // We keep the generic type
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFDF4), // Top Color
            Color(0xFFD9D7CE), // Bottom Color
          ],
        ),
      ),
      // 1. We wrap the Scaffold in a Theme
      child: Theme(
        // 2. We copy the current app theme, but force the AppBar to be transparent!
        data: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0, // Removes the drop shadow
            scrolledUnderElevation: 0, // Prevents color change when scrolling
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // 3. Now we can just pass the appBar directly without errors!
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}