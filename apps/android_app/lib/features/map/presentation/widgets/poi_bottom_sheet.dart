// lib/features/map/presentation/widgets/poi_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/tema_provider.dart';
import '../../domain/models/poi_model.dart';
import '../providers/map_provider.dart';
import '../providers/favorites_provider.dart';

class PoiBottomSheet extends ConsumerWidget {
  final PoiModel poi;
  const PoiBottomSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s           = ref.watch(mapProvider).value;
    final temaColors  = ref.watch(temaColoresProvider);
    final favoritos   = ref.watch(favoritesProvider);
    final enItinerario = s?.poisParaItinerario.any((p) => p.id == poi.id) ?? false;
    final esFav        = favoritos.any((p) => p.id == poi.id);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: temaColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _PoiImage(poi: poi, temaColors: temaColors),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nombre + badge Muul ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        poi.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Botón corazón favoritos
                    GestureDetector(
                      onTap: () =>
                          ref.read(favoritesProvider.notifier).toggleFavorito(poi),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: esFav
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: esFav
                                ? AppColors.accent
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          esFav ? Icons.favorite : Icons.favorite_border,
                          color: esFav ? AppColors.accent : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                    if (poi.verificado) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: temaColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: temaColors.secondary),
                        ),
                        child: Text(
                          '✓ Muul',
                          style: TextStyle(
                              color: temaColors.secondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // ── Categoría ────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: temaColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    poi.categoria.toUpperCase(),
                    style: TextStyle(
                      color: temaColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ── Descripción ──────────────────────────────────────────
                if (poi.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    poi.descripcion,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],

                // ── Horario ──────────────────────────────────────────────
                if (poi.horario != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: temaColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        poi.horario!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // ── Botones de acción ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: temaColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.directions_walk, size: 18),
                        label: const Text('Ir aquí'),
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(mapProvider.notifier).calcularRutaAPoi(poi);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: enItinerario
                            ? AppColors.accent
                            : temaColors.secondary,
                        side: BorderSide(
                          color: enItinerario
                              ? AppColors.accent
                              : temaColors.secondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                          enItinerario ? Icons.remove : Icons.add, size: 18),
                      label: Text(enItinerario ? 'Quitar' : 'Itinerario'),
                      onPressed: () {
                        ref
                            .read(mapProvider.notifier)
                            .togglePoiItinerario(poi);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoiImage extends StatelessWidget {
  final PoiModel poi;
  final TemaColors temaColors;
  const _PoiImage({required this.poi, required this.temaColors});

  IconData _iconForCategoria(String cat) {
    switch (cat.toLowerCase()) {
      case 'restaurant':
      case 'comida':       return Icons.restaurant;
      case 'museum':
      case 'cultura':      return Icons.museum;
      case 'market':
      case 'tienda':       return Icons.shopping_bag;
      case 'park':         return Icons.park;
      case 'cafe':         return Icons.coffee;
      case 'historic':     return Icons.account_balance;
      default:             return Icons.place;
    }
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: temaColors.primary.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_iconForCategoria(poi.categoria),
              color: temaColors.secondary, size: 48),
          const SizedBox(height: 8),
          Text(poi.nombre,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (poi.foto != null && poi.foto!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: poi.foto!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }
}