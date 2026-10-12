import 'package:flutter/material.dart';

/// Log in to book
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class LoginToBookView extends StatelessWidget {
  const LoginToBookView({super.key});

  static const route = '/auth/login-to-book';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in to book')),
      body: const Center(child: Text('TODO: Log in to book')),
    );
  }
}
