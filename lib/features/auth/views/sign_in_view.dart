import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';
import '../state/auth_validators.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/google_auth_mixin.dart';
import 'verify_phone_view.dart';

/// Sign in or register
/// Module 1 - Auth and onboarding  |  Owner: A
/// Google (main), email, or phone OTP. Works for both "create account" and "log in".
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  static const route = '/auth/sign-in';

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with GoogleAuthMixin<SignInView> {
  bool _emailBusy = false;

  bool get _isLogin => AuthFlow.mode == AuthMode.login;

  void _toggleMode() {
    setState(() {
      AuthFlow.mode = _isLogin ? AuthMode.register : AuthMode.login;
      authError = null;
    });
  }

  Future<void> _openEmailSheet() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Theme(
        data: uiFeatureTheme(context, UiColors.teal),
        child: _EmailSheet(isLogin: _isLogin, repo: authRepo),
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      _emailBusy = true;
      authError = null;
    });
    try {
      await AuthFlow.afterSignIn(context, authRepo);
    } catch (e) {
      if (mounted) setState(() => authError = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _emailBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthFlow.role;
    final busy = googleLoading || _emailBusy;

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: _isLogin ? 'Log in' : 'Sign up',
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              AuthHero(
                icon: _isLogin ? Icons.lock_open_rounded : Icons.person_add_alt_1_rounded,
                title: _isLogin ? 'Welcome back' : 'Create your account',
                subtitle: _isLogin
                    ? 'Log in to continue with LocaLink.'
                    : (role != null ? 'Signing up as ${role.displayName}' : 'Sign up to continue.'),
              ),
              AuthErrorBanner(authError),
              const SizedBox(height: 28),
              UiMainButton(
                label: 'Continue with Google',
                icon: Icons.login_rounded,
                isLoading: googleLoading,
                onPressed: busy ? null : continueWithGoogle,
              ),
              const SizedBox(height: 10),
              UiGhostButton(
                label: 'Use email',
                icon: Icons.mail_outline_rounded,
                onPressed: busy ? null : _openEmailSheet,
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: busy ? null : () => Navigator.pushNamed(context, VerifyPhoneView.route),
                child: uiText(
                  'Use phone number (OTP) instead',
                  size: 13,
                  weight: FontWeight.w700,
                  color: UiColors.teal,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: busy ? null : _toggleMode,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: uiText(
                    _isLogin ? 'New here? Create account' : 'Already registered? Log in',
                    size: 13,
                    weight: FontWeight.w700,
                    color: UiColors.muted,
                    align: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailSheet extends StatefulWidget {
  final bool isLogin;
  final AuthRepository repo;
  const _EmailSheet({required this.isLogin, required this.repo});

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!AuthValidators.isEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      if (widget.isLogin) {
        await widget.repo.signInWithEmail(email, password);
      } else {
        await widget.repo.registerWithEmail(email, password);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (!AuthValidators.isEmail(email)) {
      setState(() => _error = 'Type your email above first, then tap Forgot password.');
      return;
    }
    try {
      await widget.repo.sendPasswordReset(email);
      if (mounted) {
        setState(() {
          _error = null;
          _info = 'Password reset link sent to $email.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = AuthRepository.friendlyError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: UiBottomSheetFrame(
        title: widget.isLogin ? 'Log in with email' : 'Create account with email',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiTextInput(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              hintText: 'you@example.com',
            ),
            const SizedBox(height: 12),
            UiTextInput(
              label: 'Password',
              controller: _password,
              obscureText: true,
              hintText: 'At least 6 characters',
            ),
            AuthErrorBanner(_error),
            if (_info != null) ...[
              const SizedBox(height: 10),
              uiText(_info!, size: 12.5, weight: FontWeight.w600, color: UiColors.teal),
            ],
            const SizedBox(height: 16),
            UiMainButton(
              label: widget.isLogin ? 'Log in' : 'Create account',
              isLoading: _busy,
              onPressed: _busy ? null : _submit,
            ),
            if (widget.isLogin)
              Center(
                child: TextButton(
                  onPressed: _busy ? null : _forgotPassword,
                  child: uiText('Forgot password?',
                      size: 12.5, weight: FontWeight.w700, color: UiColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}