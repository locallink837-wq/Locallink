import 'package:flutter/material.dart';

/// Map
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class MapView extends StatelessWidget {
  const MapView({super.key});

  static const route = '/browse/map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: const Center(child: Text('TODO: Map')),
    );
  }
}
