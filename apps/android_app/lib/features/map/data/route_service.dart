// lib/features/map/data/route_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../domain/models/poi_model.dart';

class RouteResult {
  final List<List<double>> coordenadas;
  final double distanciaMetros;
  final double duracionSegundos;
  final List<String> instrucciones;

  RouteResult({
    required this.coordenadas,
    required this.distanciaMetros,
    required this.duracionSegundos,
    required this.instrucciones,
  });

  String get distanciaTexto {
    if (distanciaMetros < 1000) return '${distanciaMetros.round()} m';
    return '${(distanciaMetros / 1000).toStringAsFixed(1)} km';
  }

  String get duracionTexto {
    final minutos = (duracionSegundos / 60).round();
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    return '${horas}h ${mins}min';
  }
}

class RouteService {
  // Base URL sin el perfil (lo inyectaremos dinámicamente)
  static const String baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  Future<List<RouteResult>> calcularRutas({
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    String perfil = 'walking', // 'driving', 'walking', 'cycling'
  }) async {
    final uri = Uri.parse(
      '$baseUrl/$perfil'
      '/$origenLng,$origenLat;$destinoLng,$destinoLat'
      '?alternatives=true'
      '&steps=true'
      '&language=es'
      '&geometries=geojson'
      '&overview=full'
      '&access_token=${AppConstants.mapboxToken}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final routes = data['routes'] as List? ?? [];
    return routes.map((r) => _parseRuta(r)).toList();
  }

  Future<ItinerarioResult> calcularItinerario({
    required double origenLat,
    required double origenLng,
    required List<PoiModel> destinos,
    String perfil = 'walking',
  }) async {
    if (destinos.isEmpty) return ItinerarioResult(etapas: [], ordenPois: []);

    final ordenados = _nearestNeighbor(
      origenLat: origenLat,
      origenLng: origenLng,
      pois: destinos,
    );

    final waypoints = StringBuffer();
    waypoints.write('$origenLng,$origenLat');
    for (final poi in ordenados) {
      waypoints.write(';${poi.longitud},${poi.latitud}');
    }

    final uri = Uri.parse(
      '$baseUrl/$perfil'
      '/${waypoints.toString()}'
      '?steps=true'
      '&language=es'
      '&geometries=geojson'
      '&overview=full'
      '&access_token=${AppConstants.mapboxToken}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return ItinerarioResult(etapas: [], ordenPois: ordenados);
    }

    final data = jsonDecode(response.body);
    final routes = data['routes'] as List? ?? [];
    if (routes.isEmpty) return ItinerarioResult(etapas: [], ordenPois: ordenados);

    final legs = routes[0]['legs'] as List? ?? [];
    final etapas = legs.asMap().entries.map((entry) {
      final leg = entry.value;
      final steps = (leg['steps'] as List? ?? [])
          .map((s) => s['maneuver']['instruction'].toString())
          .toList();
      return EtapaItinerario(
        desde: entry.key == 0 ? 'Tu ubicación' : ordenados[entry.key - 1].nombre,
        hasta: ordenados[entry.key].nombre,
        distanciaMetros: (leg['distance'] as num).toDouble(),
        duracionSegundos: (leg['duration'] as num).toDouble(),
        instrucciones: steps,
      );
    }).toList();

    return ItinerarioResult(etapas: etapas, ordenPois: ordenados);
  }

  Future<List<List<double>>> obtenerCoordsItinerario({
    required double origenLat,
    required double origenLng,
    required List<PoiModel> destinos,
    String perfil = 'walking',
  }) async {
    if (destinos.isEmpty) return [];

    final waypoints = StringBuffer();
    waypoints.write('$origenLng,$origenLat');
    for (final poi in destinos) {
      waypoints.write(';${poi.longitud},${poi.latitud}');
    }

    final uri = Uri.parse(
      '$baseUrl/$perfil'
      '/${waypoints.toString()}'
      '?geometries=geojson'
      '&overview=full'
      '&access_token=${AppConstants.mapboxToken}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final routes = data['routes'] as List? ?? [];
    if (routes.isEmpty) return [];

    return (routes[0]['geometry']['coordinates'] as List)
        .map((c) => [(c[0] as num).toDouble(), (c[1] as num).toDouble()])
        .toList();
  }

  List<PoiModel> _nearestNeighbor({
    required double origenLat,
    required double origenLng,
    required List<PoiModel> pois,
  }) {
    final pendientes = List<PoiModel>.from(pois);
    final resultado = <PoiModel>[];
    double currentLat = origenLat;
    double currentLng = origenLng;

    while (pendientes.isNotEmpty) {
      PoiModel? nearest;
      double menorDistancia = double.infinity;

      for (final poi in pendientes) {
        final dist = _distancia(currentLat, currentLng, poi.latitud, poi.longitud);
        if (dist < menorDistancia) {
          menorDistancia = dist;
          nearest = poi;
        }
      }

      if (nearest != null) {
        resultado.add(nearest);
        pendientes.remove(nearest);
        currentLat = nearest.latitud;
        currentLng = nearest.longitud;
      }
    }

    return resultado;
  }

  double _distancia(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  RouteResult _parseRuta(Map<String, dynamic> route) {
    final coords = (route['geometry']['coordinates'] as List)
        .map((c) => [
              (c[0] as num).toDouble(),
              (c[1] as num).toDouble(),
            ])
        .toList();

    final legs = route['legs'] as List? ?? [];
    final instrucciones = <String>[];
    for (final leg in legs) {
      for (final step in (leg['steps'] as List? ?? [])) {
        instrucciones.add(step['maneuver']['instruction'].toString());
      }
    }

    return RouteResult(
      coordenadas: coords,
      distanciaMetros: (route['distance'] as num).toDouble(),
      duracionSegundos: (route['duration'] as num).toDouble(),
      instrucciones: instrucciones,
    );
  }
}

class EtapaItinerario {
  final String desde;
  final String hasta;
  final double distanciaMetros;
  final double duracionSegundos;
  final List<String> instrucciones;

  EtapaItinerario({
    required this.desde,
    required this.hasta,
    required this.distanciaMetros,
    required this.duracionSegundos,
    required this.instrucciones,
  });

  String get duracionTexto {
    final m = (duracionSegundos / 60).round();
    return m < 60 ? '$m min' : '${m ~/ 60}h ${m % 60}min';
  }
}

class ItinerarioResult {
  final List<EtapaItinerario> etapas;
  final List<PoiModel> ordenPois;

  ItinerarioResult({required this.etapas, required this.ordenPois});

  double get distanciaTotal =>
      etapas.fold(0, (sum, e) => sum + e.distanciaMetros);

  double get duracionTotal =>
      etapas.fold(0, (sum, e) => sum + e.duracionSegundos);
}