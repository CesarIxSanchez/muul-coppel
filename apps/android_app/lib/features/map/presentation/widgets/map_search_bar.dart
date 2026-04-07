// lib/features/map/presentation/widgets/map_search_bar.dart
import '../providers/map_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/tema_provider.dart';
import '../../domain/models/poi_model.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapSearchBar extends ConsumerStatefulWidget {
  const MapSearchBar({super.key});

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _hasFocus = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(mapProvider.notifier).buscar(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mapProvider).value;
    final temaColors = ref.watch(temaColoresProvider);
    final results = s?.searchResults ?? [];
    final isLoading = s?.isLoadingSearch ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Barra de búsqueda ────────────────────────────────────────────
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasFocus
                  ? temaColors.secondary
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Focus(
                  onFocusChange: (v) => setState(() => _hasFocus = v),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Buscar lugares, calles, ciudades…',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(temaColors.secondary),
                    ),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                  onPressed: () {
                    _controller.clear();
                    ref.read(mapProvider.notifier).limpiarBusqueda();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),

        // ── Lista de sugerencias ─────────────────────────────────────────
        if (results.isNotEmpty && _hasFocus)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length.clamp(0, 6),
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              itemBuilder: (_, i) {
                final poi = results[i];
                return _SuggestionTile(
                  poi: poi,
                  onTap: () {
                    _controller.text = poi.nombre;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: poi.nombre.length),
                    );
                    ref.read(mapProvider.notifier).seleccionarPoi(poi);
                    // Centrar mapa en el resultado
                    final ctrl = ref.read(mapProvider).value?.mapController;
                    ctrl?.flyTo(
                      CameraOptions(
                        center: Point(
                          coordinates: Position(poi.longitud, poi.latitud),
                        ),
                        zoom: 16.0,
                      ),
                      MapAnimationOptions(duration: 800),
                    );
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final PoiModel poi;
  final VoidCallback onTap;

  const _SuggestionTile({required this.poi, required this.onTap});

  IconData _iconForCategoria(String cat) {
    switch (cat.toLowerCase()) {
      case 'restaurant':
      case 'comida':
      case 'food':
        return Icons.restaurant;
      case 'museum':
      case 'cultura':
        return Icons.museum;
      case 'market':
      case 'tienda':
      case 'shop':
        return Icons.shopping_bag;
      case 'park':
        return Icons.park;
      case 'cafe':
        return Icons.coffee;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              _iconForCategoria(poi.categoria),
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (poi.descripcion.isNotEmpty)
                    Text(
                      poi.descripcion,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.north_west, color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}