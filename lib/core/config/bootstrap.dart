import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';
import 'env.dart';

/// App start-up. Owner: A.
/// Every step is wrapped in try/catch so the app (and the /dev screen launcher)
/// still runs before Firebase / Supabase are configured.
Future<void> bootstrap() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously(); // guest mode
    }
  } catch (e) {
    debugPrint('Firebase not ready: $e');
  }

  try {
    if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        accessToken: () async => await FirebaseAuth.instance.currentUser?.getIdToken(),
      );
    }
  } catch (e) {
    debugPrint('Supabase not ready: $e');
  }
}
