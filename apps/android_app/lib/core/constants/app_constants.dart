// lib/core/constants/app_constants.dart
import 'env.dart';

class AppConstants {
  // ── Mapbox ──────────────────────────────────────────────────
  static String get mapboxToken => mapboxPublicToken;

  static const String mapboxStyleDark =
      'mapbox://styles/mapbox/dark-v11';

  static const String mapboxDirectionsUrl =
      'https://api.mapbox.com/directions/v5/mapbox/walking';

  static const String mapboxSearchUrl =
      'https://api.mapbox.com/search/searchbox/v1/category';

  // ── Supabase ─────────────────────────────────────────────────
  static String get supabaseUrl => supabaseUrlEnv;
  static String get supabaseAnonKey => supabaseAnonKeyEnv;

  // ── API Real de Vercel (opcional) ─────────────────────────────
  static const String prodApiBaseUrl = 'https://muul-api.vercel.app/api/v1';

  // ── Geofencing ───────────────────────────────────────────────
  static const double geofenceRadiusMeters = 50.0;

  // ── Animaciones ──────────────────────────────────────────────
  static const Duration markerAnimDuration = Duration(milliseconds: 350);
  static const Duration markerCascadeDelay = Duration(milliseconds: 40);
}