import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar; 
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton, 
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
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
        image: const DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover, 
          opacity: 0.1, 
        ),
      ),
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
          // 🚀 FIX: Wrap the body in a SafeArea to protect from landscape notches,
          // but set top and bottom to false because your scroll views handle that.
          body: SafeArea(
            left: true,
            right: true,
            top: false,
            bottom: false,
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton, 
        ),
      ),
    );
  }
}