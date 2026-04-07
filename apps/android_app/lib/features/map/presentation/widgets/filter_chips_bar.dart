// lib/features/map/presentation/widgets/filter_chips_bar.dart
import '../providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/tema_provider.dart';
import '../../../../core/constants/app_colors.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  static const _filtros = [
    _Filtro('comida',   Icons.restaurant,  'Comida'),
    _Filtro('cultura',  Icons.museum,      'Cultura'),
    _Filtro('tienda',   Icons.shopping_bag,'Tiendas'),
    _Filtro('park',     Icons.park,        'Parques'),
    _Filtro('cafe',     Icons.coffee,      'Cafés'),
    _Filtro('historic', Icons.account_balance, 'Historia'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(mapProvider).value;
    final temaColors = ref.watch(temaColoresProvider);
    final activos = s?.categoriasFiltro ?? {};

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filtro = _filtros[i];
          final activo = activos.contains(filtro.key);

          return GestureDetector(
            onTap: () =>
                ref.read(mapProvider.notifier).toggleFiltro(filtro.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: activo
                    ? temaColors.secondary
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo
                      ? temaColors.secondary
                      : Colors.white.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filtro.icon,
                    size: 14,
                    color: activo ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    filtro.label,
                    style: TextStyle(
                      color: activo ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: activo
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Filtro {
  final String key;
  final IconData icon;
  final String label;
  const _Filtro(this.key, this.icon, this.label);
}