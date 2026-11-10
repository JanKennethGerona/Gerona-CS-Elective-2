/// Supabase configuration credentials.
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project credentials
/// obtained from your Supabase Dashboard:
/// Project Settings -> API -> Project URL & Project API Keys (anon public).
class SupabaseConfig {
  static const String supabaseUrl = 'https://pfzxwjnzegrbqrpxmbfw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmenh3am56ZWdyYnFycHhtYmZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyNDIzNTksImV4cCI6MjEwOTgxODM1OX0.onCUYXT_NeqnZOcGkEClPo0pqczy9FTbcXqgGJXat5Q';

  /// Returns true if valid custom credentials have been specified.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        supabaseUrl.startsWith('https://');
  }
}
