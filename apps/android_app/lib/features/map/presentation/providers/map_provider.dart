// lib/features/map/presentation/providers/map_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/services/location_service.dart';
import '../../data/poi_repository.dart';
import '../../data/route_service.dart';
import '../../domain/models/poi_model.dart';

// ← ELIMINADO: import de explore_provider que no existía

class MapState {
  final geo.Position? userPosition;
  final bool isLoadingLocation;
  final String? locationError;
  final MapboxMap? mapController;
  final bool mapReady;

  final List<PoiModel> pois;
  final bool isLoadingPois;
  final PoiModel? poiSeleccionado;

  final String categoriaActiva;
  final String searchQuery;

  final List<RouteResult> rutasAlternativas;
  final int rutaActivaIndex;
  final bool isLoadingRuta;

  final List<PoiModel> poisParaItinerario;
  final ItinerarioResult? itinerario;
  final List<List<double>> itinerarioCoords;
  final bool isLoadingItinerario;

  final List<PoiModel> searchResults;
  final bool isLoadingSearch;

  final String perfilTransporte;

  const MapState({
    this.userPosition,
    this.isLoadingLocation = false,
    this.locationError,
    this.mapController,
    this.mapReady = false,
    this.pois = const [],
    this.isLoadingPois = false,
    this.poiSeleccionado,
    this.categoriaActiva = '',
    this.searchQuery = '',
    this.rutasAlternativas = const [],
    this.rutaActivaIndex = 0,
    this.isLoadingRuta = false,
    this.poisParaItinerario = const [],
    this.itinerario,
    this.itinerarioCoords = const [],
    this.isLoadingItinerario = false,
    this.searchResults = const [],
    this.isLoadingSearch = false,
    this.perfilTransporte = 'walking',
  });

  List<PoiModel> get poisFiltrados {
    var list = pois;
    if (categoriaActiva.isNotEmpty) {
      list = list
          .where((p) =>
              p.categoria.toLowerCase() == categoriaActiva.toLowerCase())
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.nombre.toLowerCase().contains(query) ||
              p.descripcion.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  MapState copyWith({
    geo.Position? userPosition,
    bool? isLoadingLocation,
    String? locationError,
    bool clearLocationError = false,
    MapboxMap? mapController,
    bool? mapReady,
    List<PoiModel>? pois,
    bool? isLoadingPois,
    PoiModel? poiSeleccionado,
    bool clearPoiSeleccionado = false,
    String? categoriaActiva,
    String? searchQuery,
    List<RouteResult>? rutasAlternativas,
    int? rutaActivaIndex,
    bool? isLoadingRuta,
    List<PoiModel>? poisParaItinerario,
    ItinerarioResult? itinerario,
    bool clearItinerario = false,
    List<List<double>>? itinerarioCoords,
    bool? isLoadingItinerario,
    List<PoiModel>? searchResults,
    bool? isLoadingSearch,
    String? perfilTransporte,
  }) {
    return MapState(
      userPosition:        userPosition        ?? this.userPosition,
      isLoadingLocation:   isLoadingLocation   ?? this.isLoadingLocation,
      locationError:       clearLocationError  ? null : (locationError ?? this.locationError),
      mapController:       mapController       ?? this.mapController,
      mapReady:            mapReady            ?? this.mapReady,
      pois:                pois                ?? this.pois,
      isLoadingPois:       isLoadingPois       ?? this.isLoadingPois,
      poiSeleccionado:     clearPoiSeleccionado ? null : (poiSeleccionado ?? this.poiSeleccionado),
      categoriaActiva:     categoriaActiva     ?? this.categoriaActiva,
      searchQuery:         searchQuery         ?? this.searchQuery,
      rutasAlternativas:   rutasAlternativas   ?? this.rutasAlternativas,
      rutaActivaIndex:     rutaActivaIndex     ?? this.rutaActivaIndex,
      isLoadingRuta:       isLoadingRuta       ?? this.isLoadingRuta,
      poisParaItinerario:  poisParaItinerario  ?? this.poisParaItinerario,
      itinerario:          clearItinerario     ? null : (itinerario ?? this.itinerario),
      itinerarioCoords:    itinerarioCoords    ?? this.itinerarioCoords,
      isLoadingItinerario: isLoadingItinerario ?? this.isLoadingItinerario,
      searchResults:       searchResults       ?? this.searchResults,
      isLoadingSearch:     isLoadingSearch     ?? this.isLoadingSearch,
      perfilTransporte:    perfilTransporte    ?? this.perfilTransporte,
    );
  }
}

class MapNotifier extends AsyncNotifier<MapState> {
  final _poiRepo  = PoiRepository();
  final _routeSvc = RouteService();

  @override
  Future<MapState> build() async => const MapState();

  Future<void> onMapCreated(MapboxMap controller) async {
    state = AsyncData(state.value!.copyWith(
      mapController: controller, mapReady: true,
    ));
    await fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    final s = state.value ?? const MapState();
    state = AsyncData(s.copyWith(
      isLoadingLocation: true, clearLocationError: true,
    ));
    try {
      final pos = await LocationService.getCurrentPosition();
      state = AsyncData((state.value ?? const MapState()).copyWith(
        userPosition: pos, isLoadingLocation: false,
      ));
      await _centerMapOnUser(pos, state.value!.mapController);
      await fetchPoisCercanos();
    } on LocationServiceException catch (e) {
      state = AsyncData((state.value ?? const MapState()).copyWith(
        isLoadingLocation: false, locationError: e.message,
      ));
    }
  }

  Future<void> fetchPoisCercanos() async {
    final s = state.value ?? const MapState();
    if (s.userPosition == null) return;
    state = AsyncData(s.copyWith(isLoadingPois: true));
    try {
      final mapPois = await _poiRepo.fetchTodosPois(
        lat: s.userPosition!.latitude,
        lng: s.userPosition!.longitude,
      );
      state = AsyncData(state.value!.copyWith(
        pois: mapPois, isLoadingPois: false,
      ));
    } catch (_) {
      state = AsyncData(state.value!.copyWith(isLoadingPois: false));
    }
  }

  // ── Filtros ───────────────────────────────────────────────────────────────

  void filtrarPorCategoria(String categoria) {
    // Toggle: si ya está activa, la quita
    final nueva = state.value?.categoriaActiva == categoria ? '' : categoria;
    state = AsyncData(state.value!.copyWith(categoriaActiva: nueva));
  }

  // Filtra localmente los POIs ya cargados por nombre/descripción
  void buscarPoi(String query) {
    state = AsyncData(state.value!.copyWith(searchQuery: query));
  }

  // Busca en Mapbox API (lugares globales con autocomplete)
  Future<void> buscar(String query) async {
    if (query.trim().isEmpty) {
      state = AsyncData(state.value!.copyWith(searchResults: []));
      return;
    }
    final s = state.value ?? const MapState();
    state = AsyncData(s.copyWith(isLoadingSearch: true));
    final results = await _poiRepo.buscarLugares(
      query: query,
      lat: s.userPosition?.latitude,
      lng: s.userPosition?.longitude,
    );
    state = AsyncData((state.value ?? const MapState()).copyWith(
      searchResults: results, isLoadingSearch: false,
    ));
  }

  void limpiarBusqueda() {
    state = AsyncData(state.value!.copyWith(searchResults: []));
  }

  // ── POIs ──────────────────────────────────────────────────────────────────

  void seleccionarPoi(PoiModel poi) =>
      state = AsyncData(state.value!.copyWith(poiSeleccionado: poi));

  void deseleccionarPoi() =>
      state = AsyncData(state.value!.copyWith(clearPoiSeleccionado: true));

  void togglePoiItinerario(PoiModel poi) {
    final s = state.value!;
    final lista = List<PoiModel>.from(s.poisParaItinerario);
    final idx = lista.indexWhere((p) => p.id == poi.id);
    if (idx >= 0) {
      lista.removeAt(idx);
      // ← CORREGIDO: ya no mutamos el modelo directamente
    } else {
      lista.add(poi);
    }
    state = AsyncData(s.copyWith(poisParaItinerario: lista));
  }

  // ── Transporte ────────────────────────────────────────────────────────────

  // ← CORREGIDO: captura s antes de cambiar state
  void cambiarTransporte(String perfil) {
    final s = state.value!;
    state = AsyncData(s.copyWith(perfilTransporte: perfil));
    if (s.itinerario != null) {
      calcularItinerario();
    } else if (s.rutasAlternativas.isNotEmpty && s.poiSeleccionado != null) {
      calcularRutaAPoi(s.poiSeleccionado!);
    }
  }

  // ── Rutas ─────────────────────────────────────────────────────────────────

  Future<void> calcularRutaAPoi(PoiModel destino) async {
    final s = state.value!;
    if (s.userPosition == null) return;
    state = AsyncData(s.copyWith(isLoadingRuta: true));
    final rutas = await _routeSvc.calcularRutas(
      origenLat: s.userPosition!.latitude,
      origenLng: s.userPosition!.longitude,
      destinoLat: destino.latitud,
      destinoLng: destino.longitud,
      perfil: s.perfilTransporte,
    );
    state = AsyncData((state.value ?? const MapState()).copyWith(
      rutasAlternativas: rutas,
      rutaActivaIndex: 0,
      isLoadingRuta: false,
    ));
  }

  Future<void> calcularItinerario() async {
    final s = state.value!;
    if (s.userPosition == null || s.poisParaItinerario.isEmpty) return;
    state = AsyncData(s.copyWith(isLoadingItinerario: true));

    final resultado = await _routeSvc.calcularItinerario(
      origenLat: s.userPosition!.latitude,
      origenLng: s.userPosition!.longitude,
      destinos: s.poisParaItinerario,
      perfil: s.perfilTransporte,
    );

    final coords = await _routeSvc.obtenerCoordsItinerario(
      origenLat: s.userPosition!.latitude,
      origenLng: s.userPosition!.longitude,
      destinos: resultado.ordenPois,
      perfil: s.perfilTransporte,
    );

    state = AsyncData((state.value ?? const MapState()).copyWith(
      itinerario: resultado,
      itinerarioCoords: coords,
      isLoadingItinerario: false,
    ));
  }

  void cambiarRutaActiva(int index) =>
      state = AsyncData(state.value!.copyWith(rutaActivaIndex: index));

  void limpiarRutas() {
    state = AsyncData(state.value!.copyWith(
      rutasAlternativas: [],
      clearItinerario: true,
      itinerarioCoords: [],
      poisParaItinerario: [],
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _centerMapOnUser(
    geo.Position pos,
    MapboxMap? ctrl,
  ) async {
    if (ctrl == null) return;
    await ctrl.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(pos.longitude, pos.latitude)),
        zoom: 15.0,
      ),
      MapAnimationOptions(duration: 1200, startDelay: 0),
    );
  }
}

final mapProvider =
    AsyncNotifierProvider<MapNotifier, MapState>(MapNotifier.new);