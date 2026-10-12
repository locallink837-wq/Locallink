import 'package:flutter/material.dart';

/// Customer info
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class CustomerInfoView extends StatelessWidget {
  const CustomerInfoView({super.key});

  static const route = '/auth/customer-info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer info')),
      body: const Center(child: Text('TODO: Customer info')),
    );
  }
}
