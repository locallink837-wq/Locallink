import 'package:flutter/material.dart';

/// Browse Services
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class BrowseServicesView extends StatelessWidget {
  const BrowseServicesView({super.key});

  static const route = '/browse/browse-services';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Services')),
      body: const Center(child: Text('TODO: Browse Services')),
    );
  }
}
