import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';

/// Screen 4.5: AI Service Unavailable Fallback.
/// Graceful fallback state providing manual category selection without interrupting the customer's repair request.
class AiUnavailableView extends StatelessWidget {
  const AiUnavailableView({super.key});

  static const route = '/assistant/ai-unavailable';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiCoverScreen(
        customAccent: UiColors.teal,
        icon: Icons.cloud_off_rounded,
        title: 'AI Analysis Unavailable',
        subtitle:
            'We could not reach Gemini AI at this moment. You can still select your service trade manually and request verified providers nearby.',
        primaryButtonText: 'Choose Service Manually',
        onPrimaryPressed: () {
          Navigator.pushReplacementNamed(
            context,
            '/requests/request-form',
            arguments: {'category': 'Plumber'},
          );
        },
        secondaryButtonText: 'Back to Assistant Hub',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
