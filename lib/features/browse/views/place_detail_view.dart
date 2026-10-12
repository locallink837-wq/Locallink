import 'package:flutter/material.dart';

/// Place detail
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({super.key});

  static const route = '/browse/place-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place detail')),
      body: const Center(child: Text('TODO: Place detail')),
    );
  }
}
