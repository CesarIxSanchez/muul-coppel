// lib/features/map/presentation/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/poi_model.dart';

class FavoritesNotifier extends Notifier<List<PoiModel>> {
  @override
  List<PoiModel> build() => [];

  void toggleFavorito(PoiModel poi) {
    final existe = state.any((p) => p.id == poi.id);
    if (existe) {
      state = state.where((p) => p.id != poi.id).toList();
    } else {
      state = [...state, poi];
    }
  }

  bool esFavorito(String poiId) => state.any((p) => p.id == poiId);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<PoiModel>>(
  FavoritesNotifier.new,
);