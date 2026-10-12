import 'package:flutter/material.dart';

/// Sign in or register
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  static const route = '/auth/sign-in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in or register')),
      body: const Center(child: Text('TODO: Sign in or register')),
    );
  }
}
