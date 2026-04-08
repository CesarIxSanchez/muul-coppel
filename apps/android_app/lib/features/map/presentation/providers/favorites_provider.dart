// lib/features/map/presentation/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/poi_model.dart';

class FavoritesNotifier extends Notifier<List<PoiModel>> {
  final _client = Supabase.instance.client;

  @override
  List<PoiModel> build() {
    _loadRemoteFavorites();
    return [];
  }

  Future<void> toggleFavorito(PoiModel poi) async {
    final existe = state.any((p) => p.id == poi.id);

    // Para lugares externos (Mapbox/POI público), mantenemos favorito local.
    if (!poi.esNegocio) {
      if (existe) {
        state = state.where((p) => p.id != poi.id).toList();
      } else {
        state = [...state, poi];
      }
      return;
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (existe) {
        state = state.where((p) => p.id != poi.id).toList();
      } else {
        state = [...state, poi];
      }
      return;
    }

    if (existe) {
      try {
        await _client
            .from('negocio_favoritos')
            .delete()
            .eq('usuario_id', userId)
            .eq('negocio_id', poi.id);
      } catch (_) {}
      state = state.where((p) => p.id != poi.id).toList();
    } else {
      try {
        await _client.from('negocio_favoritos').upsert(
          {'usuario_id': userId, 'negocio_id': poi.id},
          onConflict: 'usuario_id,negocio_id',
        );
      } catch (_) {}
      state = [...state, poi];
    }
  }

  bool esFavorito(String poiId) => state.any((p) => p.id == poiId);

  Future<void> _loadRemoteFavorites() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final rows = await _client
          .from('negocio_favoritos')
          .select('negocio_id')
          .eq('usuario_id', userId);

      final remote = (rows as List)
          .map((row) => PoiModel(
                id: row['negocio_id'] as String,
                nombre: '',
                categoria: 'negocio',
                descripcion: '',
                latitud: 0,
                longitud: 0,
                esNegocio: true,
              ))
          .toList();

      if (remote.isNotEmpty) {
        final merged = [...state];
        for (final fav in remote) {
          if (!merged.any((p) => p.id == fav.id)) {
            merged.add(fav);
          }
        }
        state = merged;
      }
    } catch (_) {
      // Si falla (tabla no creada todavía), no interrumpimos UX local.
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<PoiModel>>(
  FavoritesNotifier.new,
);