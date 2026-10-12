import 'package:flutter/material.dart';

/// No provider found
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class NoProviderFoundView extends StatelessWidget {
  const NoProviderFoundView({super.key});

  static const route = '/requests/no-provider-found';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No provider found')),
      body: const Center(child: Text('TODO: No provider found')),
    );
  }
}
