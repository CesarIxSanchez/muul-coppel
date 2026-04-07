import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:data/data.dart';
import '../../../../core/constants/app_constants.dart';

// ── Providers de Configuración ──────────────────────────────────────────────

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepository(
    client: http.Client(),
    baseUrl: AppConstants.prodApiBaseUrl,
  );
});

// ── Filtros de Búsqueda y Categorías ────────────────────────────────────────

// Estado global de la barra de búsqueda superior
final searchQueryProvider = StateProvider<String>((ref) => '');

// Categoría seleccionada para flitrar el catálogo
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ── Fetching de Datos Reales ───────────────────────────────────────────────

// Lista total de POIs del backend
final poisProvider = FutureProvider<List<Place>>((ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.fetchPois();
});

// POIs filtrados por búsqueda y categoría
final filteredPoisProvider = Provider<AsyncValue<List<Place>>>((ref) {
  final poisAsync = ref.watch(poisProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCat = ref.watch(selectedCategoryProvider);

  return poisAsync.whenData((pois) {
    return pois.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(query) || 
                           p.description.toLowerCase().contains(query);
      
      final matchesCat = selectedCat == null || 
                         p.category.toLowerCase() == selectedCat.toLowerCase();
      
      return matchesQuery && matchesCat;
    }).toList();
  });
});

// ── Tipos Especializados ───────────────────────────────────────────────────

final businessProvider = Provider<AsyncValue<List<Business>>>((ref) {
  final poisAsync = ref.watch(filteredPoisProvider);
  return poisAsync.whenData((pois) => pois.whereType<Business>().toList());
});

final placesOnlyProvider = Provider<AsyncValue<List<Place>>>((ref) {
  final poisAsync = ref.watch(filteredPoisProvider);
  return poisAsync.whenData((pois) => pois.where((p) => p is! Business).toList());
});
