import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';

/// Screen 5.7: Guest Requests and Profile Gated State.
/// Displayed when anonymous visitors attempt to view their profile or booking history.
/// Contains Sign up and Log in buttons navigating to auth routes.
class GuestRequestsProfileView extends StatelessWidget {
  const GuestRequestsProfileView({super.key});

  static const route = '/safety-profile/guest-requests-profile';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
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
                    color: UiColors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    size: 48,
                    color: UiColors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                uiText('Sign in to view your profile', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 10),
                uiText(
                  'Create an account or sign in to track your service requests, saved places, and message verified providers.',
                  size: 13.5,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.4,
                ),
                const Spacer(),

                UiMainButton(
                  label: 'Sign up',
                  customAccent: UiColors.teal,
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth/sign-up-gate');
                  },
                ),
                const SizedBox(height: 12),

                UiGhostButton(
                  label: 'Log in',
                  customAccent: UiColors.teal,
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth/sign-in');
                  },
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
