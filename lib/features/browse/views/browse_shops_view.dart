import 'package:flutter/material.dart';

/// Browse Shops
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class BrowseShopsView extends StatelessWidget {
  const BrowseShopsView({super.key});

  static const route = '/browse/browse-shops';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Shops')),
      body: const Center(child: Text('TODO: Browse Shops')),
    );
  }
}
