import 'package:flutter/material.dart';

/// LocaLink colours: teal = Services, indigo = Places, amber = Shops, red = SOS only.
class AppColors {
  static const teal = Color(0xFF0E5E63);
  static const indigo = Color(0xFF3D4F9F);
  static const amber = Color(0xFFB97800);
  static const red = Color(0xFFC0392B);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
    // TODO: add Plus Jakarta Sans in pubspec fonts and set fontFamily here.
  );
}
