import 'package:flutter/material.dart';

/// Saved places
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SavedPlacesView extends StatelessWidget {
  const SavedPlacesView({super.key});

  static const route = '/browse/saved-places';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved places')),
      body: const Center(child: Text('TODO: Saved places')),
    );
  }
}
