class Env {
  /// true = app opens on the screen launcher (/dev). Set false for real flow.
  static const bool startWithDevMenu = true;

  // Safe to ship in the app. Real values come from --dart-define-from-file=env/dev.json
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
