import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../state/auth_flow.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/google_auth_mixin.dart';
import 'sign_in_view.dart';

/// Log in to book
/// Module 1 - Auth and onboarding  |  Owner: A
/// Opened when a guest taps Request / Urgent request. After login the person is brought back here.
class LoginToBookView extends StatefulWidget {
  const LoginToBookView({super.key});

  static const route = '/auth/login-to-book';

  @override
  State<LoginToBookView> createState() => _LoginToBookViewState();
}

class _LoginToBookViewState extends State<LoginToBookView> with GoogleAuthMixin<LoginToBookView> {
  @override
  void initState() {
    super.initState();
    AuthFlow.beginInline(startMode: AuthMode.login);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Log in to book',
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const AuthHero(
                icon: Icons.lock_outline_rounded,
                title: 'Log in to book',
                subtitle: 'Sign in to send this request. We bring you back here.',
              ),
              AuthErrorBanner(authError),
            ],
          ),
        ),
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Continue with Google',
              icon: Icons.login_rounded,
              isLoading: googleLoading,
              onPressed: googleLoading ? null : continueWithGoogle,
            ),
            const SizedBox(height: 10),
            UiGhostButton(
              label: 'Create account',
              onPressed: googleLoading
                  ? null
                  : () {
                      AuthFlow.beginInline(); // register mode, customer
                      Navigator.pushNamed(context, SignInView.route);
                    },
            ),
          ],
        ),
      ),
    );
  }
}