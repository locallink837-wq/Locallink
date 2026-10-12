import 'package:flutter/material.dart';

/// Request accepted
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class RequestAcceptedView extends StatelessWidget {
  const RequestAcceptedView({super.key});

  static const route = '/requests/request-accepted';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request accepted')),
      body: const Center(child: Text('TODO: Request accepted')),
    );
  }
}
