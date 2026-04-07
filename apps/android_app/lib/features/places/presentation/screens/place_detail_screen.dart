import 'package:flutter/material.dart';
import 'package:data/data.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Place? place = ModalRoute.of(context)?.settings.arguments as Place?;

    return Scaffold(
      backgroundColor: const Color(0xFF111113),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF111113),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(place?.name ?? 'Lugar', style: const TextStyle(color: Colors.white, fontSize: 16)),
              background: Container(
                color: const Color(0xFF242426),
                child: const Center(
                  child: Icon(Icons.location_on_outlined, color: Color(0xFF599265), size: 64),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place != null && place.category.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF599265).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(color: Color(0xFF599265), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Descripción',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place?.description ?? 'Sin descripción disponible.',
                    style: TextStyle(color: Colors.grey[400], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const _InfoPill(icon: Icons.access_time, text: 'Información general'),
                      const SizedBox(width: 8),
                      if (place?.isVerified ?? false)
                        const _InfoPill(icon: Icons.verified, text: 'Verificado'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF599265),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        // Aquí se podría disparar la navegación al mapa con este punto
                        Navigator.pushNamed(context, '/map', arguments: place);
                      },
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text('Trazar Ruta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF599265), size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[300], fontSize: 13)),
        ],
      ),
    );
  }
}
