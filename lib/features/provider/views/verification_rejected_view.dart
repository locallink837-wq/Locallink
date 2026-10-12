import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/ui_kit.dart';
import 'register_core_view.dart';

/// Screen: Verification Rejected (tagged NEW in design).
/// Shows rejection reason with options to "Fix and resubmit" or "Contact support".
class VerificationRejectedView extends StatelessWidget {
  const VerificationRejectedView({super.key});

  static const route = '/provider/verification-rejected';

  void _contactSupport(BuildContext context) async {
    final uri = Uri.parse('mailto:support@localink.app?subject=Provider Verification Inquiry');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final reason = args['rejectionReason'] as String? ?? 'ID photo or selfie was not clearly legible.';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Centered Warning Icon
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: UiColors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 44,
                    color: UiColors.red,
                  ),
                ),
                const SizedBox(height: 24),
                uiText('We could not verify you yet', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 16),

                // Rejection reason banner
                UiWarningBanner(
                  text: 'Reason: $reason',
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 14),
                uiText(
                  'Please review your document submissions to ensure all names, details, and photos are sharp and well-lit.',
                  size: 13,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.4,
                ),
                const Spacer(),

                // Fix and resubmit button (returns to 6.1)
                UiMainButton(
                  label: 'Fix and resubmit',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, RegisterCoreView.route, (r) => false);
                  },
                ),
                const SizedBox(height: 12),

                // Contact support ghost button
                UiGhostButton(
                  label: 'Contact support',
                  onPressed: () => _contactSupport(context),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
