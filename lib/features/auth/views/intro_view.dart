import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';
import 'language_view.dart';

/// Intro
/// Module 1 - Auth and onboarding  |  Owner: A
class IntroView extends StatelessWidget {
  const IntroView({super.key});

  static const route = '/auth/intro';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiCoverScreen(
        icon: Icons.travel_explore_rounded,
        title: 'Services, Places and Shops near you',
        subtitle: 'Find trusted plumbers, hospitals, hardware shops and more around you.',
        primaryButtonText: 'Get started',
        onPrimaryPressed: () {
          AuthFlow.beginOnboarding();
          Navigator.pushNamed(context, LanguageView.route);
        },
        secondaryButtonText: 'Skip, explore as guest',
        onSecondaryPressed: () => AuthFlow.goGuestHome(
          Navigator.of(context),
          const AuthRepository(),
        ),
      ),
    );
  }
}