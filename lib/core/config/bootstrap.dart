import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';
import 'env.dart';

/// App bootstrap & service initialization.
/// Owner: Person A (Leader).
/// Initializes Firebase and Supabase with resilient fallbacks
/// so the UI and Dev screen launcher (/dev) can run even before backend credentials are wired.
Future<void> bootstrap() async {
  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');

    // Auto sign-in anonymously for Guest Mode if no active session
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in anonymously for guest browsing.');
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // 2. Initialize Supabase
  try {
    if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: Env.supabaseAnonKey,
        accessToken: () async {
          return await FirebaseAuth.instance.currentUser?.getIdToken();
        },
      );
      debugPrint('Supabase initialized successfully.');
    } else {
      debugPrint('Supabase credentials empty: running in offline/mock storage mode.');
    }
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }
}
