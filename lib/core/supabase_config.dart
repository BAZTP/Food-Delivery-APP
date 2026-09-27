class SupabaseConfig {
  // Pega aquí los datos obtenidos de tu panel de Supabase:
  // Project Settings > API > Project URL
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  // Project Settings > API > Project API keys > anon / public
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
