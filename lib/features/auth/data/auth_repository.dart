import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/app_user.dart';
import '../../../core/services/location_service.dart';

/// Module 1 - Auth and onboarding
/// ALL Firebase calls for this feature live here (screens never call Firebase directly).
/// Firestore paths come from core/constants/firestore_paths.dart.

/// Error with a message that is safe to show to the user.
class AuthFailure implements Exception {
  final String message;
  final bool cancelled;
  const AuthFailure(this.message) : cancelled = false;
  const AuthFailure.cancelled() : message = '', cancelled = true;
  @override
  String toString() => message;
}

class DetectedLocation {
  final double lat;
  final double lng;
  final String area;
  const DetectedLocation(this.lat, this.lng, this.area);
}

/// Where to send the user next (route name + optional arguments).
class AuthDestination {
  final String route;
  final Object? arguments;
  const AuthDestination(this.route, {this.arguments});
}

/// Route names owned by OTHER features. We use strings so auth never imports
/// another feature's files (team rule 2).
class AuthTargets {
  static const intro = '/auth/intro';
  static const roleChoice = '/auth/role-choice';
  static const customerInfo = '/auth/customer-info';

  static const guestHome = '/browse/guest-home';

  static const customerShell = '/shell/customer';
  static const providerShell = '/shell/provider';
  static const vendorShell = '/shell/vendor';

  static const providerRegister = '/provider/register-core';
  static const providerPending = '/provider/pending';
  static const providerRejected = '/provider/verification-rejected';

  static const shopRegister = '/vendor/register-shop';
  static const placeRegister = '/vendor/register-place';
}

class AuthRepository {
  const AuthRepository();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static bool _googleReady = false;

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null; // Firebase not initialised (dev mode)
    }
  }

  String? get currentUid => currentUser?.uid;

  /// true = real account (Google / phone / email). Guests are anonymous.
  bool get isRealUser {
    final u = currentUser;
    return u != null && !u.isAnonymous;
  }

  /// Guests browse Places and Shops with an anonymous session.
  Future<void> ensureGuestSession() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> signOutToGuest() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
    await _auth.signInAnonymously();
  }

  // ---------------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------------

  /// Signs in with Google. Does NOT create a Firestore profile: the profile is
  /// created later with the role the person chose.
  Future<User> signInWithGoogle() async {
    try {
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize();
        _googleReady = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'Google did not return a login token. Please try again.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null)
        throw const AuthFailure('Login failed. Please try again.');
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure.cancelled();
      }
      debugPrint('Google sign-in error: $e');
      throw const AuthFailure(
        'Google sign-in failed. Check your internet and try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(friendlyError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final r = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return r.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(friendlyError(e));
    }
  }

  Future<User> registerWithEmail(String email, String password) async {
    try {
      final r = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return r.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(friendlyError(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(friendlyError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Phone OTP
  // ---------------------------------------------------------------------------

  Future<void> sendOtp({
    required String phoneE164,
    int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onFailed,
    required void Function() onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneE164,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (credential) async {
          try {
            await _auth.signInWithCredential(credential);
            onAutoVerified();
          } on FirebaseAuthException catch (e) {
            onFailed(friendlyError(e));
          }
        },
        verificationFailed: (e) => onFailed(friendlyError(e)),
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      onFailed(friendlyError(e));
    }
  }

  Future<User> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final r = await _auth.signInWithCredential(credential);
      return r.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(friendlyError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Profile: users/{uid}
  // ---------------------------------------------------------------------------

  Future<AppUser?> fetchProfile(String uid) async {
    final snap = await _db.collection(FsPaths.users).doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = Map<String, dynamic>.from(snap.data()!);
    final created = data['createdAt'];
    if (created is Timestamp) data['createdAt'] = created.toDate();
    return AppUser.fromMap(snap.id, data);
  }

  /// Creates the profile once. The role can never change afterwards (Firestore rule).
  Future<AppUser> createProfile({
    required String uid,
    required UserRole role,
    String name = '',
    String phone = '',
    String email = '',
    String area = '',
    String language = 'en',
    String photoUrl = '',
    bool onboardingDone = true,
  }) async {
    await _db.collection(FsPaths.users).doc(uid).set({
      'role': role.name,
      'name': name,
      'phone': phone,
      'email': email,
      'area': area,
      'language': language,
      'onboardingDone': onboardingDone,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return AppUser(
      uid: uid,
      role: role.name,
      name: name,
      phone: phone,
      email: email,
      area: area,
      language: language,
      onboardingDone: onboardingDone,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Never include 'role' here (rules block role changes).
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) {
    return _db.collection(FsPaths.users).doc(uid).update(fields);
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await currentUser?.updateDisplayName(name);
    } catch (_) {}
  }

  Future<void> saveLocation({
    required String uid,
    String? area,
    double? lat,
    double? lng,
  }) {
    return updateProfile(uid, {
      if (area != null && area.trim().isNotEmpty) 'area': area.trim(),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // Location (permission + reverse geocode)
  // ---------------------------------------------------------------------------

  /// Returns null when the person denies permission.
  Future<DetectedLocation?> detectLocation() async {
    const service = LocationService();
    final permission = await service.requestPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return null;
    }
    final pos = await service.getCurrentPosition();
    String area = '';
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        area = [p.subLocality, p.locality]
            .where((s) => s != null && s.trim().isNotEmpty)
            .map((s) => s!.trim())
            .join(', ');
      }
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
    }
    return DetectedLocation(pos.latitude, pos.longitude, area);
  }

  // ---------------------------------------------------------------------------
  // Where should this account go after login?
  // ---------------------------------------------------------------------------

  Future<AuthDestination> destinationFor(AppUser u) async {
    switch (u.parsedRole) {
      case UserRole.customer:
        return const AuthDestination(AuthTargets.customerShell);

      case UserRole.provider:
        try {
          final snap = await _db.collection(FsPaths.providers).doc(u.uid).get();
          if (!snap.exists)
            return const AuthDestination(AuthTargets.providerRegister);
          final data = snap.data() ?? {};
          final status = (data['verificationStatus'] ?? 'draft')
              .toString()
              .toLowerCase();
          switch (status) {
            case 'approved':
              return const AuthDestination(AuthTargets.providerShell);
            case 'pending':
              return const AuthDestination(AuthTargets.providerPending);
            case 'rejected':
              return AuthDestination(
                AuthTargets.providerRejected,
                arguments: {
                  'rejectionReason':
                      (data['rejectionReason'] ??
                              'Documents could not be verified.')
                          .toString(),
                },
              );
            default:
              return const AuthDestination(AuthTargets.providerRegister);
          }
        } catch (e) {
          debugPrint('Provider status lookup failed: $e');
          return const AuthDestination(AuthTargets.providerShell);
        }

      case UserRole.shopOwner:
      case UserRole.placeOwner:
        final registerRoute = u.parsedRole == UserRole.shopOwner
            ? AuthTargets.shopRegister
            : AuthTargets.placeRegister;
        try {
          final q = await _db
              .collection(FsPaths.listings)
              .where('ownerId', isEqualTo: u.uid)
              .limit(1)
              .get();
          if (q.docs.isEmpty) return AuthDestination(registerRoute);
          return const AuthDestination(AuthTargets.vendorShell);
        } catch (e) {
          debugPrint('Listing lookup failed: $e');
          return const AuthDestination(AuthTargets.vendorShell);
        }
    }
  }

  /// Route for a brand-new owner/provider account (role form).
  String roleFormRoute(UserRole role) {
    switch (role) {
      case UserRole.provider:
        return AuthTargets.providerRegister;
      case UserRole.shopOwner:
        return AuthTargets.shopRegister;
      case UserRole.placeOwner:
        return AuthTargets.placeRegister;
      case UserRole.customer:
        return AuthTargets.customerInfo;
    }
  }

  // ---------------------------------------------------------------------------
  // Friendly errors
  // ---------------------------------------------------------------------------

  static String friendlyError(Object e) {
    if (e is AuthFailure) return e.message;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address does not look right.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in instead.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'network-request-failed':
          return 'No internet connection. Please try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes and try again.';
        case 'invalid-phone-number':
          return 'Enter a valid 10-digit mobile number.';
        case 'invalid-verification-code':
          return 'That OTP is not correct. Please check and try again.';
        case 'session-expired':
        case 'code-expired':
          return 'The OTP expired. Please request a new one.';
        case 'quota-exceeded':
          return 'SMS limit reached for now. Please try again later.';
        case 'operation-not-allowed':
          return 'This login method is not enabled yet. Ask the team to enable it in Firebase.';
        case 'account-exists-with-different-credential':
          return 'This email is registered with another login method.';
        default:
          return e.message ?? 'Login failed. Please try again.';
      }
    }
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'You do not have permission to do that. Please log in again.';
      }
      if (e.code == 'unavailable')
        return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
