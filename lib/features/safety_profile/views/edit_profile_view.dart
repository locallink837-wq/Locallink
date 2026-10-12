import 'package:flutter/material.dart';

/// Edit profile
/// Module 5 - SOS and profile  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  static const route = '/safety-profile/edit-profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: const Center(child: Text('TODO: Edit profile')),
    );
  }
}
