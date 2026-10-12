import 'package:flutter/material.dart';

/// Request history
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class RequestHistoryView extends StatelessWidget {
  const RequestHistoryView({super.key});

  static const route = '/requests/request-history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request history')),
      body: const Center(child: Text('TODO: Request history')),
    );
  }
}
