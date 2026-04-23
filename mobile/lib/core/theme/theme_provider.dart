import 'package:flutter/material.dart';

// This is a global variable that holds our current theme state.
// We default it to light mode, but you can change it to ThemeMode.system 
// if you want it to match the user's phone settings by default.
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.system);