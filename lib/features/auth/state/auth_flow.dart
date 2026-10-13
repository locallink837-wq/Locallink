import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/models/app_user.dart';
import '../data/auth_repository.dart';

enum AuthMode { register, login }

/// Small in-memory state for the onboarding / login flow + navigation helpers.
///
/// Two ways to arrive at the auth screens:
///  1. Onboarding: Splash > Intro > Language > Role > Sign in > role form > Home.
///  2. Inline (a guest tapped Services / Request / Sign up inside the app):
///     after login we pop back to the screen the person came from.
class AuthFlow {
  AuthFlow._();

  static String language = 'en'; // en | hi | mr
  static UserRole? role; // chosen on the Role choice screen
  static AuthMode mode = AuthMode.register;
  static bool _inline = false;

  /// Inline when started from a gate, or when no role was chosen (opened from inside the app).
  static bool get isInline => _inline || role == null;

  static void reset() {
    language = 'en';
    role = null;
    mode = AuthMode.register;
    _inline = false;
  }

  static void beginOnboarding() {
    role = null;
    mode = AuthMode.register;
    _inline = false;
  }

  static void chooseRole(UserRole r, {bool login = false}) {
    role = r;
    mode = login ? AuthMode.login : AuthMode.register;
    _inline = false;
  }

  /// Called by Sign up gate and Log in to book (guests inside the app).
  static void beginInline({AuthMode startMode = AuthMode.register}) {
    role = UserRole.customer;
    mode = startMode;
    _inline = true;
  }

  // ---------------------------------------------------------------------------
  // Decide the first screen after Splash
  // ---------------------------------------------------------------------------
  static Future<AuthDestination> startDestination(AuthRepository repo) async {
    await repo.ensureGuestSession();
    final user = repo.currentUser;
    if (user == null || user.isAnonymous) {
      return const AuthDestination(AuthTargets.intro);
    }
    final profile = await repo.fetchProfile(user.uid);
    if (profile == null) {
      // Logged in but never finished creating the account.
      return const AuthDestination(AuthTargets.roleChoice);
    }
    if (!profile.onboardingDone && profile.isCustomer) {
      return const AuthDestination(AuthTargets.customerInfo);
    }
    return repo.destinationFor(profile);
  }

  // ---------------------------------------------------------------------------
  // After ANY successful login (Google, email, phone)
  // ---------------------------------------------------------------------------
  static Future<void> afterSignIn(BuildContext context, AuthRepository repo) async {
    final user = repo.currentUser;
    if (user == null || user.isAnonymous) return;

    // Grab these before awaiting so we never touch a stale context.
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final profile = await repo.fetchProfile(user.uid);

    // Existing account: the stored role always wins (role never changes).
    if (profile != null) {
      if (!profile.onboardingDone && profile.isCustomer) {
        nav.pushNamed(AuthTargets.customerInfo);
        return;
      }
      await _goHome(nav, repo, profile);
      return;
    }

    // "Log in" but no account exists yet.
    if (mode == AuthMode.login && !isInline) {
      mode = AuthMode.register;
      messenger.showSnackBar(const SnackBar(
        content: Text('No LocaLink account found. Choose a role to create one.'),
      ));
      nav.pushNamed(AuthTargets.roleChoice);
      return;
    }

    // New account.
    final r = role ?? UserRole.customer;
    if (r == UserRole.customer) {
      nav.pushNamed(AuthTargets.customerInfo); // profile is created there
      return;
    }

    final fallbackName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? '');
    await repo.createProfile(
      uid: user.uid,
      role: r,
      name: fallbackName,
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      language: language,
      photoUrl: user.photoURL ?? '',
    );
    nav.pushNamedAndRemoveUntil(repo.roleFormRoute(r), (_) => false);
  }

  static Future<void> _goHome(NavigatorState nav, AuthRepository repo, AppUser profile) async {
    if (isInline) {
      returnToApp(nav);
      return;
    }
    final dest = await repo.destinationFor(profile);
    nav.pushNamedAndRemoveUntil(dest.route, (_) => false, arguments: dest.arguments);
  }

  /// End of the customer onboarding (after location).
  static void finishOnboarding(NavigatorState nav) {
    if (isInline) {
      returnToApp(nav);
    } else {
      nav.pushNamedAndRemoveUntil(AuthTargets.customerShell, (_) => false);
    }
  }

  /// Pops every /auth/ screen and lands on the screen the person came from.
  static void returnToApp(NavigatorState nav) {
    var landedOnAuth = false;
    nav.popUntil((route) {
      final isAuth = (route.settings.name ?? '').startsWith('/auth/');
      if (route.isFirst || !isAuth) {
        landedOnAuth = isAuth;
        return true;
      }
      return false;
    });
    if (landedOnAuth) {
      nav.pushNamedAndRemoveUntil(AuthTargets.customerShell, (_) => false);
    }
  }

  /// Guest mode: Places, Shops and SOS stay open.
  static Future<void> goGuestHome(NavigatorState nav, AuthRepository repo) async {
    try {
      await repo.ensureGuestSession();
    } catch (_) {}
    nav.pushNamedAndRemoveUntil(AuthTargets.guestHome, (_) => false);
  }
}