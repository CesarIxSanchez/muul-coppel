import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:data/data.dart';
import '../providers/explore_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(filteredPoisProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SearchFieldStitch(
                      hintText: 'Buscar lugares...',
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF599265),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    query.isEmpty ? 'Lugares Populares' : 'Resultados',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: resultsAsync.when(
                  data: (pois) {
                    if (pois.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron resultados.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: pois.length,
                      itemBuilder: (context, index) {
                        final p = pois[index];
                        return _SearchResultItem(
                          poi: p,
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Place poi;
  final VoidCallback onTap;

  const _SearchResultItem({required this.poi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        poi is Business ? Icons.storefront : Icons.location_on,
        color: const Color(0xFF599265),
        size: 20,
      ),
      title: Text(poi.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
      subtitle: Text(poi.category, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Icon(Icons.north_west, color: Colors.grey[700], size: 16),
      onTap: onTap,
    );
  }
}
