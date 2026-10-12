import 'package:flutter/material.dart';

/// Vendor dashboard
/// Module 7 - Shop and place owner  |  Owner: C
/// Replace the body below with your real UI. Keep the class name and route.
class VendorDashboardView extends StatelessWidget {
  const VendorDashboardView({super.key});

  static const route = '/vendor/vendor-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor dashboard')),
      body: const Center(child: Text('TODO: Vendor dashboard')),
    );
  }
}
