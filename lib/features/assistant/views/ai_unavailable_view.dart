import 'package:flutter/material.dart';

/// AI unavailable
/// Module 4 - AI assistant and New to City  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class AiUnavailableView extends StatelessWidget {
  const AiUnavailableView({super.key});

  static const route = '/assistant/ai-unavailable';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI unavailable')),
      body: const Center(child: Text('TODO: AI unavailable')),
    );
  }
}
