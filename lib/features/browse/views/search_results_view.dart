import 'package:flutter/material.dart';

/// Search results
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  static const route = '/browse/search-results';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search results')),
      body: const Center(child: Text('TODO: Search results')),
    );
  }
}
