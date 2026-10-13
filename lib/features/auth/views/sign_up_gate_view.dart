import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../state/auth_flow.dart';
import '../widgets/google_auth_mixin.dart';

/// Sign up gate
/// Module 1 - Auth and onboarding  |  Owner: A
/// Shown when a guest opens Services. Places and Shops stay open.
/// After sign-up the person is returned to where they were.
class SignUpGateView extends StatefulWidget {
  const SignUpGateView({super.key});

  static const route = '/auth/sign-up-gate';

  @override
  State<SignUpGateView> createState() => _SignUpGateViewState();
}

class _SignUpGateViewState extends State<SignUpGateView> with GoogleAuthMixin<SignUpGateView> {
  @override
  void initState() {
    super.initState();
    AuthFlow.beginInline();
  }

  @override
  void onAuthError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _explore() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      AuthFlow.goGuestHome(nav, authRepo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiCoverScreen(
        icon: Icons.verified_user_rounded,
        title: 'Create an account to browse services and book',
        subtitle: 'Places and Shops are open to everyone. Services need an account so providers can trust requests.',
        primaryButtonText: googleLoading ? 'Signing in...' : 'Continue with Google',
        onPrimaryPressed: googleLoading ? null : continueWithGoogle,
        secondaryButtonText: 'Explore Places and Shops',
        onSecondaryPressed: googleLoading ? null : _explore,
      ),
    );
  }
}