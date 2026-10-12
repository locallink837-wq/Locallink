import 'package:flutter/material.dart';

/// Active job
/// Module 6 - Service provider  |  Owner: C
/// Replace the body below with your real UI. Keep the class name and route.
class ActiveJobView extends StatelessWidget {
  const ActiveJobView({super.key});

  static const route = '/provider/active-job';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active job')),
      body: const Center(child: Text('TODO: Active job')),
    );
  }
}
