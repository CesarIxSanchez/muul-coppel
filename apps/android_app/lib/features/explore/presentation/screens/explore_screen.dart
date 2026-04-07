import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:data/data.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poisAsync = ref.watch(filteredPoisProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header con posibilidad de borrar filtro
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF599265),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedCat != null ? 'Categoría: $selectedCat' : 'Catálogo de Lugares',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  if (selectedCat != null || searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(selectedCategoryProvider.notifier).state = null;
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      child: const Text('Limpiar', style: TextStyle(color: Color(0xFF599265))),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Search Bar que actualiza el estado global
              SearchFieldStitch(
                hintText: 'Encuentra restaurantes, parques...',
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
              const SizedBox(height: 16),

              Expanded(
                child: poisAsync.when(
                  data: (pois) {
                    if (pois.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron resultados para tu búsqueda.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: pois.length,
                      itemBuilder: (context, index) {
                        final p = pois[index];
                        return ExploreCard(
                          title: p.name,
                          subtitle: p.description,
                          category: p.category,
                          onTap: () {
                            if (p is Business) {
                              Navigator.pushNamed(context, '/business_detail', arguments: p);
                            } else {
                              Navigator.pushNamed(context, '/place_detail', arguments: p);
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () => _buildShimmerList(),
                  error: (e, _) => Center(
                    child: Text('Error al cargar catálogo: $e', 
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
