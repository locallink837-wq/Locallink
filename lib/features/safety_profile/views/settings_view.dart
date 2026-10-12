import 'package:flutter/material.dart';

/// Settings
/// Module 5 - SOS and profile  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const route = '/safety-profile/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('TODO: Settings')),
    );
  }
}
