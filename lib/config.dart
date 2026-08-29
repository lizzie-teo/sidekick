// Supabase credentials, supplied at build time so they stay out of source
// control.
//
// Run with:
//   flutter run --dart-define-from-file=env.json
//
// env.json is gitignored. Copy env.example.json to env.json and fill it in.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  // The client-side key, an `sb_publishable_` one. Legacy `anon` JWT keys are
  // being retired by Supabase; new projects should use a publishable key.
  static const String publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
