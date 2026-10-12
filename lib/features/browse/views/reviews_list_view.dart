import 'package:flutter/material.dart';

/// Reviews list
/// Module 2 - Browse (home, lists, detail, map)  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ReviewsListView extends StatelessWidget {
  const ReviewsListView({super.key});

  static const route = '/browse/reviews-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews list')),
      body: const Center(child: Text('TODO: Reviews list')),
    );
  }
}
