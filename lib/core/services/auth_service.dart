import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/firestore_paths.dart';
import '../models/app_user.dart';

/// Firebase Authentication & User Profile Service.
/// Handles Guest Anonymous auth, Phone OTP, Google Sign-In, and Firestore profile synchronization.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Current authenticated Firebase user
  User? get currentUser => _auth.currentUser;

  /// Current user's UID or empty string if unauthenticated
  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether current session is guest / anonymous
  bool get isGuest => _auth.currentUser == null || _auth.currentUser!.isAnonymous;

  /// Sign in anonymously for guest browsing
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  /// Sign in with Google account (using google_sign_in 7.x)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleAccount = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Ensure user profile document exists in Firestore
      final uid = userCredential.user?.uid;
      if (uid != null) {
        final doc = await _firestore.collection(FsPaths.users).doc(uid).get();
        if (!doc.exists) {
          final newUser = AppUser(
            uid: uid,
            role: 'customer',
            name: googleAccount.displayName ?? '',
            email: googleAccount.email,
            photoUrl: googleAccount.photoUrl ?? '',
            onboardingDone: false,
          );
          await saveUserProfile(newUser);
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Send Phone OTP verification code
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      debugPrint('Error sending phone verification: $e');
      rethrow;
    }
  }

  /// Verify OTP code and sign in
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Register new user with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Error registering with email: $e');
      rethrow;
    }
  }

  /// Fetch user profile from Firestore `users/{uid}`
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(FsPaths.users).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('Error fetching user profile for $uid: $e');
      return null;
    }
  }

  /// Save or update user profile document in Firestore
  Future<void> saveUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection(FsPaths.users)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Sign out current user (and sign in anonymously as guest)
  Future<void> signOut() async {
    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await _auth.signOut();
      await signInAnonymously();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
