import 'package:flutter/material.dart';
import 'package:data/data.dart';

class BusinessDetailScreen extends StatelessWidget {
  const BusinessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Business? business = ModalRoute.of(context)?.settings.arguments as Business?;

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
              title: Text(business?.name ?? 'Negocio', style: const TextStyle(color: Colors.white, fontSize: 16)),
              background: Container(
                color: const Color(0xFF242426),
                child: const Center(
                  child: Icon(Icons.storefront_outlined, color: Color(0xFF599265), size: 64),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF599265).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      business?.category ?? 'Comercio',
                      style: const TextStyle(color: Color(0xFF599265), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acerca del negocio',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    business?.description ?? 'Establecimiento local registrado en Muul.',
                    style: TextStyle(color: Colors.grey[400], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Recursos ficticios (podrían venir de meta-data en el futuro)
                  const Text(
                    'Recursos',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                       _ResourceChip(label: '📶 Wi-Fi'),
                       _ResourceChip(label: '🥡 Para llevar'),
                       _ResourceChip(label: '💳 Tarjeta'),
                       _ResourceChip(label: '🅿️ Estacionamiento'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contacto (Datos reales si existen)
                  const Text(
                    'Contacto',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const _ContactTile(icon: Icons.access_time_outlined, text: 'Consulte horario en sucursal'),
                  if (business?.isVerified ?? false)
                    const _ContactTile(icon: Icons.verified_user_outlined, text: 'Negocio Verificado por Muul'),

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
                        Navigator.pushNamed(context, '/map', arguments: business);
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

class _ResourceChip extends StatelessWidget {
  final String label;
  const _ResourceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF599265).withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF599265), size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
