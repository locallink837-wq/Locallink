import 'package:flutter/material.dart';

/// Shop detail
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ShopDetailView extends StatelessWidget {
  const ShopDetailView({super.key});

  static const route = '/browse/shop-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop detail')),
      body: const Center(child: Text('TODO: Shop detail')),
    );
  }
}
