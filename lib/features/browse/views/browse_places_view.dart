import 'package:flutter/material.dart';

/// Browse Places
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class BrowsePlacesView extends StatelessWidget {
  const BrowsePlacesView({super.key});

  static const route = '/browse/browse-places';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Places')),
      body: const Center(child: Text('TODO: Browse Places')),
    );
  }
}
