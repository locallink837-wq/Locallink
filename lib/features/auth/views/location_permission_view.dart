import 'package:flutter/material.dart';

/// Location permission
/// Module 1 - Auth and onboarding  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class LocationPermissionView extends StatelessWidget {
  const LocationPermissionView({super.key});

  static const route = '/auth/location-permission';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location permission')),
      body: const Center(child: Text('TODO: Location permission')),
    );
  }
}
