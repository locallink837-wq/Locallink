import 'package:flutter/material.dart';

/// Guest Home
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class GuestHomeView extends StatelessWidget {
  const GuestHomeView({super.key});

  static const route = '/browse/guest-home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest Home')),
      body: const Center(child: Text('TODO: Guest Home')),
    );
  }
}
