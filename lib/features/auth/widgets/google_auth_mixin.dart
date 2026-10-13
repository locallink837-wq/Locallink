import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../state/auth_flow.dart';

/// Shared "Continue with Google" behaviour for Sign in, Sign up gate and Log in to book.
mixin GoogleAuthMixin<T extends StatefulWidget> on State<T> {
  final AuthRepository authRepo = const AuthRepository();
  bool googleLoading = false;
  String? authError;

  /// Override to show the error differently (e.g. a SnackBar on cover screens).
  void onAuthError(String message) {
    setState(() => authError = message);
  }

  Future<void> continueWithGoogle() async {
    if (googleLoading) return;
    setState(() {
      googleLoading = true;
      authError = null;
    });
    try {
      await authRepo.signInWithGoogle();
      if (!mounted) return;
      await AuthFlow.afterSignIn(context, authRepo);
    } on AuthFailure catch (e) {
      if (mounted && !e.cancelled) onAuthError(e.message);
    } catch (e) {
      if (mounted) onAuthError(AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => googleLoading = false);
    }
  }
}