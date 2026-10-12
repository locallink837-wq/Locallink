import 'package:flutter/material.dart';

/// Provider dashboard
/// Module 6 - Service provider  |  Owner: C
/// Replace the body below with your real UI. Keep the class name and route.
class ProviderDashboardView extends StatelessWidget {
  const ProviderDashboardView({super.key});

  static const route = '/provider/provider-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider dashboard')),
      body: const Center(child: Text('TODO: Provider dashboard')),
    );
  }
}
