import 'dart:io';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const useProdApi = String.fromEnvironment('USE_PROD_API', defaultValue: 'false') == 'true';
  static const prodApiBaseUrl = String.fromEnvironment(
    'PROD_API_BASE_URL',
    defaultValue: 'https://muul-api.vercel.app/api/v1',
  );
  static const localApiBaseUrl = String.fromEnvironment('LOCAL_API_BASE_URL', defaultValue: '');

  static bool get hasSupabaseConfig => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get apiBaseUrl {
    if (useProdApi) return prodApiBaseUrl;
    if (localApiBaseUrl.isNotEmpty) return localApiBaseUrl;
    // Android emulator cannot access localhost directly.
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }
}
