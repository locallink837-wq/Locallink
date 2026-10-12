import 'package:flutter/material.dart';

/// Intro
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class IntroView extends StatelessWidget {
  const IntroView({super.key});

  static const route = '/auth/intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intro')),
      body: const Center(child: Text('TODO: Intro')),
    );
  }
}
