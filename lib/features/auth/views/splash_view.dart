import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';

/// Splash
/// Module 1 - Auth and onboarding  |  Owner: A
/// Decides where to go: Intro (new / guest), or straight to the right Home for a logged-in user.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  static const route = '/auth/splash';

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    AuthFlow.reset();
    const repo = AuthRepository();
    final started = DateTime.now();

    var dest = const AuthDestination(AuthTargets.intro);
    try {
      dest = await AuthFlow.startDestination(repo).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Splash routing fell back to Intro: $e');
    }

    final remaining = const Duration(milliseconds: 1400) - DateTime.now().difference(started);
    if (!remaining.isNegative) await Future<void>.delayed(remaining);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, dest.route, arguments: dest.arguments);
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF07383B);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [UiColors.teal, dark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 22),
              uiText('LocaLink', size: 32, weight: FontWeight.w800, color: Colors.white),
              const SizedBox(height: 8),
              uiText(
                'Find help near you',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const Spacer(flex: 3),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}