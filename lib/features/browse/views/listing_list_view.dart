import 'package:flutter/material.dart';

/// Listing list
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ListingListView extends StatelessWidget {
  const ListingListView({super.key});

  static const route = '/browse/listing-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing list')),
      body: const Center(child: Text('TODO: Listing list')),
    );
  }
}
