import 'package:flutter/material.dart';

/// Task detail
/// Module 4 - AI assistant and New to City  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key});

  static const route = '/assistant/task-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task detail')),
      body: const Center(child: Text('TODO: Task detail')),
    );
  }
}
