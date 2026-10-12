import 'package:flutter/material.dart';

/// Checklist
/// Module 4 - AI assistant and New to City  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class ChecklistView extends StatelessWidget {
  const ChecklistView({super.key});

  static const route = '/assistant/checklist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist')),
      body: const Center(child: Text('TODO: Checklist')),
    );
  }
}
