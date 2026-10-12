import 'package:flutter/material.dart';

/// Splash
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static const route = '/auth/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splash')),
      body: const Center(child: Text('TODO: Splash')),
    );
  }
}
