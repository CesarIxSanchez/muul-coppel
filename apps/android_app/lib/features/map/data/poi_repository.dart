// lib/features/map/data/poi_repository.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/poi_model.dart';

class PoiRepository {
  final _supabase = Supabase.instance.client;

  // ── 1. BUSCAR LUGARES CERCANOS (EXPLORACIÓN) ────────────────────────────────

  Future<List<PoiModel>> fetchMapboxPois({
    required double lat,
    required double lng,
  }) async {
    const categorias = 'restaurant,museum,historic,attraction,park,market,cafe';
    
    final uri = Uri.parse(
      '${AppConstants.mapboxSearchUrl}/$categorias'
      '?access_token=${AppConstants.mapboxToken}'
      '&proximity=$lng,$lat'
      '&limit=15'
      '&language=es',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      
      final data = jsonDecode(response.body);
      final features = data['features'] as List? ?? [];
      
      return features
          .map((f) => PoiModel.fromMapbox(f as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PoiModel>> fetchSupabasePois({
    required double lat,
    required double lng,
    double radioKm = 3.0,
  }) async {
    try {
      // Bounding box simple para filtrar por área
      final latDelta = radioKm / 111.0;
      final lngDelta = radioKm / (111.0 * cos(lat * pi / 180));

      // Buscamos tanto negocios privados como POIs públicos
      final responseNegocios = await _supabase
          .from('negocios') // 
          .select()
          .gte('latitud', lat - latDelta) // [cite: 33]
          .lte('latitud', lat + latDelta)
          .gte('longitud', lng - lngDelta)
          .lte('longitud', lng + lngDelta)
          .eq('activo', true);

      final responsePois = await _supabase
          .from('pois') // 
          .select()
          .gte('latitud', lat - latDelta) // [cite: 68]
          .lte('latitud', lat + latDelta)
          .gte('longitud', lng - lngDelta)
          .lte('longitud', lng + lngDelta)
          .eq('activo', true);

      final negocios = (responseNegocios as List)
          .map((e) => PoiModel.fromSupabase(e as Map<String, dynamic>, esNegocio: true));
          
      final pois = (responsePois as List)
          .map((e) => PoiModel.fromSupabase(e as Map<String, dynamic>, esNegocio: false));

      return [...negocios, ...pois];
    } catch (e) {
      return [];
    }
  }

  Future<List<PoiModel>> fetchTodosPois({
    required double lat,
    required double lng,
  }) async {
    // Ejecutamos ambas consultas al mismo tiempo
    final results = await Future.wait([
      fetchSupabasePois(lat: lat, lng: lng),
      fetchMapboxPois(lat: lat, lng: lng),
    ]);
    
    // Priorizamos los resultados de Supabase (negocios locales) sobre los de Mapbox
    return [...results[0], ...results[1]];
  }

  // ── 2. BÚSQUEDA DE TEXTO (AUTOCOMPLETE / BUSCADOR) ──────────────────────────

  Future<List<PoiModel>> buscarLugares({
    required String query,
    double? lat,
    double? lng,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    
    // 1. Buscar en la BD local de Muul (prioridad máxima)
    List<PoiModel> resultadosSupabase = [];
    try {
      final negRes = await _supabase
          .from('negocios') // 
          .select()
          .ilike('nombre', '%$cleanQuery%')
          .eq('activo', true)
          .limit(5);
          
      resultadosSupabase.addAll((negRes as List).map(
        (e) => PoiModel.fromSupabase(e as Map<String, dynamic>, esNegocio: true)
      ));
    } catch (_) {}

    // 2. Buscar en Mapbox usando el endpoint /forward (que SÍ devuelve coordenadas)
    List<PoiModel> resultadosMapbox = [];
    final proximity = (lat != null && lng != null) ? '&proximity=$lng,$lat' : '';
    
    final uri = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/forward' // Cambio crítico aquí
      '?q=${Uri.encodeComponent(query)}'
      '&access_token=${AppConstants.mapboxToken}'
      '&language=es'
      '&limit=5'
      '&types=poi,address'
      '$proximity',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List? ?? [];
        resultadosMapbox = features
            .map((f) => PoiModel.fromMapbox(f as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Devolvemos primero los negocios registrados en la app, luego los de Mapbox
    return [...resultadosSupabase, ...resultadosMapbox];
  }
}