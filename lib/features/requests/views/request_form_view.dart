import 'package:flutter/material.dart';

/// Request form
/// Module 3 - Service request  |  Owner: B
/// Replace the body below with your real UI. Keep the class name and route.
class RequestFormView extends StatelessWidget {
  const RequestFormView({super.key});

  static const route = '/requests/request-form';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request form')),
      body: const Center(child: Text('TODO: Request form')),
    );
  }
}
