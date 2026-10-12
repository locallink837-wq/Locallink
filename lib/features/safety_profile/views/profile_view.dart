import 'package:flutter/material.dart';

/// Profile
/// Module 5 - SOS and profile  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const route = '/safety-profile/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('TODO: Profile')),
    );
  }
}
