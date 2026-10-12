import 'package:flutter/material.dart';

/// Role choice
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class RoleChoiceView extends StatelessWidget {
  const RoleChoiceView({super.key});

  static const route = '/auth/role-choice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role choice')),
      body: const Center(child: Text('TODO: Role choice')),
    );
  }
}
