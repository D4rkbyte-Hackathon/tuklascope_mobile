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
        // 2. Your existing gradient acts as the base layer
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode 
            ? const [
                Color(0xFF121212),
                Color(0xFF050505),
              ]
            : const [
                Color(0xFFFFFDF4),
                Color(0xFFD9D7CE),
              ],
        ),
        // 3. Add the texture image overlay here
        image: const DecorationImage(
          image: AssetImage('assets/images/background.png'),
          // Use BoxFit.cover if it's a full-screen image. 
          // If it's a small seamless texture tile, change this to:
          // repeat: ImageRepeat.repeat,
          fit: BoxFit.cover, 
          
          // 4. Lower the opacity to make it a subtle texture (0.0 to 1.0)
          opacity: 0.1, 
          
          // Optional: If you want Photoshop-like blending (e.g., Multiply, Overlay)
          // instead of simple opacity, uncomment the colorFilter below:
          // colorFilter: ColorFilter.mode(Colors.grey, BlendMode.overlay),
        ),
      ),
      // 5. We wrap the Scaffold in a Theme
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0, 
            scrolledUnderElevation: 0, 
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}