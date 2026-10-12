import 'package:flutter/material.dart';

/// Chat
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  static const route = '/requests/chat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('TODO: Chat')),
    );
  }
}
