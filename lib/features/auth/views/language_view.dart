import 'package:flutter/material.dart';

/// Language
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  static const route = '/auth/language';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: const Center(child: Text('TODO: Language')),
    );
  }
}
