/// Supabase configuration credentials.
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials
/// obtained from your Supabase Dashboard:
/// Project Settings -> API -> Project URL & Project API Keys (anon public).
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Returns true if valid custom credentials have been specified.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        supabaseUrl.startsWith('https://');
  }
}

