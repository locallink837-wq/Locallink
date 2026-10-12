import 'package:flutter/material.dart';

/// Verify phone
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class VerifyPhoneView extends StatelessWidget {
  const VerifyPhoneView({super.key});

  static const route = '/auth/verify-phone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify phone')),
      body: const Center(child: Text('TODO: Verify phone')),
    );
  }
}
