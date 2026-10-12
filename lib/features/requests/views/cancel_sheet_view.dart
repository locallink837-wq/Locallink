import 'package:flutter/material.dart';

/// Cancel sheet
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class CancelSheetView extends StatelessWidget {
  const CancelSheetView({super.key});

  static const route = '/requests/cancel-sheet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel sheet')),
      body: const Center(child: Text('TODO: Cancel sheet')),
    );
  }
}
