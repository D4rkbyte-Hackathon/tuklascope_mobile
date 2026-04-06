import 'package:flutter/material.dart';

/// Provides bottom-tab navigation from deep descendants without importing [MainNavigation].
class MainNavScope extends InheritedWidget {
  final void Function(int index) goToTab;

  const MainNavScope({super.key, required this.goToTab, required super.child});

  static MainNavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavScope>();
  }

  @override
  bool updateShouldNotify(covariant MainNavScope oldWidget) =>
      goToTab != oldWidget.goToTab;
}
