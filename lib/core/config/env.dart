class Env {
  /// Set to true with --dart-define=START_WITH_DEV_MENU=true to open the screen launcher.
  /// Default is false so `flutter run` enters the real app flow (Splash > Intro > Login).
  static const bool startWithDevMenu = bool.fromEnvironment(
    'START_WITH_DEV_MENU',
    defaultValue: false,
  );

  // Safe to ship in the app. Real values come from --dart-define-from-file=env/dev.json
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Emergency SOS Dispatch Hotline
  static const String emergencyPhone = '112';

  // Demo fallback coordinates (Pune/Maharashtra center)
  static const double defaultLatitude = 18.5204;
  static const double defaultLongitude = 73.8567;
  static const String defaultAreaLabel = 'Shivajinagar, Pune';

  // Network & Request timeouts
  static const Duration requestTimeout = Duration(seconds: 15);
}
