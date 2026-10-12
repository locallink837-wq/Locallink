import 'package:flutter/material.dart';

/// Sign up gate
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SignUpGateView extends StatelessWidget {
  const SignUpGateView({super.key});

  static const route = '/auth/sign-up-gate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up gate')),
      body: const Center(child: Text('TODO: Sign up gate')),
    );
  }
}
