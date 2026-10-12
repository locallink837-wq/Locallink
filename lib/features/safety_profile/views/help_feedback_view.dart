import 'package:flutter/material.dart';

/// Help and feedback
/// Module 5 - SOS and profile  |  Owner: A
/// Replace the body below with your real UI. Keep the class name and route.
class HelpFeedbackView extends StatelessWidget {
  const HelpFeedbackView({super.key});

  static const route = '/safety-profile/help-feedback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help and feedback')),
      body: const Center(child: Text('TODO: Help and feedback')),
    );
  }
}
