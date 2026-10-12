import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import 'lead_inbox_view.dart';

/// Screen: Lead Expired (Tagged NEW in UI/UX E_F).
/// Shown when a lead request has reached its timeout window.
class LeadExpiredView extends StatelessWidget {
  const LeadExpiredView({super.key});

  static const route = '/provider/lead-expired';

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: UiColors.muted.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off_outlined,
                    size: 44,
                    color: UiColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                uiText('This request has expired', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 12),
                uiText(
                  'The customer request has timed out or was closed by the user. No fee was charged.',
                  size: 13.5,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.4,
                ),
                const Spacer(),
                UiMainButton(
                  label: 'Back to inbox',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, LeadInboxView.route, (r) => false);
                  },
                ),
                const SizedBox(height: 12),
                UiGhostButton(
                  label: 'See new leads',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, LeadInboxView.route, (r) => false);
                  },
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
