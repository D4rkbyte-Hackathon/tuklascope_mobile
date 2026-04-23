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
    // 1. Check if the app is currently in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // 2. Apply the correct gradient based on the theme
          colors: isDarkMode 
            ? const [
                Color(0xFF121212), // Top Color: Your primary dark background
                Color(0xFF050505), // Bottom Color: A subtle darker shade for depth
              ]
            : const [
                Color(0xFFFFFDF4), // Top Color: Original light background
                Color(0xFFD9D7CE), // Bottom Color: Original light bottom shade
              ],
        ),
      ),
      // 3. We wrap the Scaffold in a Theme
      child: Theme(
        // 4. We copy the current app theme, but force the AppBar to be transparent!
        data: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0, // Removes the drop shadow
            scrolledUnderElevation: 0, // Prevents color change when scrolling
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // 5. Now we can just pass the appBar directly without errors!
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}