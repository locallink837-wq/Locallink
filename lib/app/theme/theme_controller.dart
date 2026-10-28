import 'package:flutter/material.dart';

/// App theme mode controller (light / dark mode).
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDark => themeMode.value == ThemeMode.dark;

  void setDarkMode(bool enableDark) {
    themeMode.value = enableDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    setDarkMode(!isDark);
  }
}
