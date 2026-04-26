import 'package:flutter/material.dart';

/// Provides bottom-tab navigation from deep descendants without importing [MainNavigation].
class MainNavScope extends InheritedWidget {
  final void Function(int index) goToTab;
  final bool isNavBarVisible; // 1. Added visibility state
  final void Function(bool visible) setNavBarVisibility; // Added callback to control nav bar

  const MainNavScope({
    super.key, 
    required this.goToTab, 
    required this.isNavBarVisible, // 2. Added to constructor
    required this.setNavBarVisibility,
    required super.child,
  });

  static MainNavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavScope>();
  }

  @override
  bool updateShouldNotify(covariant MainNavScope oldWidget) {
    // 3. Notify descendants if either the tab function or the visibility changes
    return goToTab != oldWidget.goToTab || isNavBarVisible != oldWidget.isNavBarVisible;
  }
}