import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _value(String key, {String fallback = ''}) {
    final runtime = dotenv.maybeGet(key)?.trim() ?? '';
    if (runtime.isNotEmpty) return runtime;
    return String.fromEnvironment(key, defaultValue: fallback).trim();
  }

  static String get supabaseUrl => _value(
        'SUPABASE_URL',
        fallback: 'https://qewqnirwuptcudoflgkd.supabase.co',
      );

  static String get supabaseAnonKey => _value(
        'SUPABASE_ANON_KEY',
        fallback:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFld3FuaXJ3dXB0Y3Vkb2ZsZ2tkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4Mzg1NjQsImV4cCI6MjA5MDQxNDU2NH0.5rUOin2SZlq-fRpWqr4Vzd97iI4JDca3-Zl7N3qy6lc',
      );
  static bool get useProdApi {
    final raw = _value('USE_PROD_API', fallback: 'true').toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static String get prodApiBaseUrl =>
      _value('PROD_API_BASE_URL', fallback: 'https://muul-api.vercel.app/api/v1');

  static String get localApiBaseUrl => _value('LOCAL_API_BASE_URL');

  static bool get hasSupabaseConfig => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get apiBaseUrl {
    if (useProdApi) return prodApiBaseUrl;
    if (localApiBaseUrl.isNotEmpty) return localApiBaseUrl;
    // Android emulator cannot access localhost directly.
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }
}
