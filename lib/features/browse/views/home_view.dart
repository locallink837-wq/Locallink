import 'package:flutter/material.dart';

/// Home
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const route = '/browse/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('TODO: Home')),
    );
  }
}
