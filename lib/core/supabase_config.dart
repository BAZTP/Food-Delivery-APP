class SupabaseConfig {
  static const String supabaseUrl = 'https://xbovfmxsiiriqfutthnt.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_Z_WehIQkbuNCrykO5NCGpg_ya_wwdrF';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
