import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/explore_provider.dart';
import '../../../../main_shell.dart';

/// Versión standalone del Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111113),
      body: SafeArea(child: _HomeBody()),
    );
  }
}

/// Versión para usar dentro del MainShell (sin Scaffold propio ni bottom nav)
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111113),
      body: SafeArea(child: _HomeBody()),
    );
  }
}

/// Contenido compartido del Home con datos reales y filtros funcionales
class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  void _onCategoryTap(WidgetRef ref, String category) {
    // 1. Establecer el filtro global
    ref.read(selectedCategoryProvider.notifier).state = category;
    // 2. Saltar a la pestaña de Catálogo (índice 1 en MainShell)
    ref.read(bottomNavIndexProvider.notifier).state = 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesOnlyProvider);
    final businessAsync = ref.watch(businessProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Bienvenido a',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Muul',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF599265),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '🌎 Muul 2026',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Search Bar ──
          SearchFieldStitch(
            hintText: 'Buscar lugares, calles, ciudades...',
            onTap: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          const SizedBox(height: 24),

          // ── Categorías con filtros activos ──
          const Text(
            'Categorías',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryButton(emoji: '🍴', label: 'Comida', onTap: () => _onCategoryTap(ref, 'Comida')),
                _CategoryButton(emoji: '🏛️', label: 'Cultura', onTap: () => _onCategoryTap(ref, 'Cultura')),
                _CategoryButton(emoji: '🛍️', label: 'Tiendas', onTap: () => _onCategoryTap(ref, 'Tiendas')),
                _CategoryButton(emoji: '🌲', label: 'Parques', onTap: () => _onCategoryTap(ref, 'Parques')),
                _CategoryButton(emoji: '⚽', label: 'Estadios', onTap: () => _onCategoryTap(ref, 'Estadios')),
                _CategoryButton(emoji: '🏨', label: 'Hoteles', onTap: () => _onCategoryTap(ref, 'Hoteles')),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Lugares Populares Reales ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lugares Populares',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                },
                child: Text('Ver todo →', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          placesAsync.when(
            data: (places) {
              if (places.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('No hay lugares disponibles en esta categoría.', style: TextStyle(color: Colors.grey[600])),
                  ),
                );
              }
              return Column(
                children: places.take(3).map((p) => ExploreCard(
                  title: p.name,
                  subtitle: p.description,
                  category: p.category,
                  onTap: () => Navigator.pushNamed(context, '/place_detail', arguments: p),
                )).toList(),
              );
            },
            loading: () => _buildShimmerList(),
            error: (e, _) => Text('Error al cargar lugares: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 32),

          // ── Negocios Destacados Reales ──
          const Text(
            'Negocios Destacados',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          businessAsync.when(
            data: (businesses) {
              if (businesses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Pronto llegarán más negocios destacados.', style: TextStyle(color: Colors.grey[600])),
                  ),
                );
              }
              return Column(
                children: businesses.take(2).map((b) => ExploreCard(
                  title: b.name,
                  subtitle: b.description,
                  category: b.category,
                  onTap: () => Navigator.pushNamed(context, '/business_detail', arguments: b),
                )).toList(),
              );
            },
            loading: () => _buildShimmerList(),
            error: (e, _) => Text('Error al cargar negocios: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        children: List.generate(2, (i) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
        )),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
