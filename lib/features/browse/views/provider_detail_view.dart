import 'package:flutter/material.dart';

/// Provider detail
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ProviderDetailView extends StatelessWidget {
  const ProviderDetailView({super.key});

  static const route = '/browse/provider-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider detail')),
      body: const Center(child: Text('TODO: Provider detail')),
    );
  }
}
