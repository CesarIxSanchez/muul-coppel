// lib/features/map/presentation/widgets/itinerary_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/route_service.dart';
import '../../../../core/theme/tema_provider.dart';
import '../providers/map_provider.dart';

class ItineraryPanel extends ConsumerStatefulWidget {
  final ItinerarioResult itinerario;
  final VoidCallback onClose;
  final TemaColors temaColors;

  const ItineraryPanel({
    super.key,
    required this.itinerario,
    required this.onClose,
    required this.temaColors,
  });

  @override
  ConsumerState<ItineraryPanel> createState() => _ItineraryPanelState();
}

class _ItineraryPanelState extends ConsumerState<ItineraryPanel> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado para saber qué botón iluminar
    final perfilActivo = ref.watch(mapProvider).value?.perfilTransporte ?? 'walking';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header con Totales ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Tu itinerario', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatDuration(widget.itinerario.duracionTotal), style: TextStyle(color: widget.temaColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_formatDistance(widget.itinerario.distanciaTotal), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: widget.onClose),
              ],
            ),
          ),

          // ── Selector de Transporte (A pie, Auto, Bici) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TransportButton(
                  icon: Icons.directions_walk, label: 'A pie', isActive: perfilActivo == 'walking',
                  onTap: () => ref.read(mapProvider.notifier).cambiarTransporte('walking'), 
                  temaColors: widget.temaColors,
                ),
                _TransportButton(
                  icon: Icons.directions_car, label: 'Auto', isActive: perfilActivo == 'driving',
                  onTap: () => ref.read(mapProvider.notifier).cambiarTransporte('driving'), 
                  temaColors: widget.temaColors,
                ),
                _TransportButton(
                  icon: Icons.directions_bike, label: 'Bici', isActive: perfilActivo == 'cycling',
                  onTap: () => ref.read(mapProvider.notifier).cambiarTransporte('cycling'), 
                  temaColors: widget.temaColors,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 24),

          // ── Lista Expansible de Etapas (Paso a Paso) ──
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.itinerario.etapas.length,
              itemBuilder: (context, i) {
                final etapa = widget.itinerario.etapas[i];
                final isExpanded = _expandedIndex == i;

                return Card(
                  color: const Color(0xFF2A2A2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Theme(
                    // Quita las líneas divisoras del ExpansionTile por defecto
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      onExpansionChanged: (expanded) => setState(() => _expandedIndex = expanded ? i : null),
                      initiallyExpanded: isExpanded,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: widget.temaColors.secondary,
                        foregroundColor: const Color(0xFF003918),
                        child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(etapa.hasta, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text('Desde: ${etapa.desde}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(etapa.duracionTexto, style: TextStyle(color: widget.temaColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(_formatDistance(etapa.distanciaMetros), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                      // ── Instrucciones Detalladas (Aparecen al tocar) ──
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF201F21),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: etapa.instrucciones.map((inst) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.turn_right, color: widget.temaColors.secondary, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(inst, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                                ],
                              ),
                            )).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double segs) {
    final m = (segs / 60).round();
    return m < 60 ? '$m min' : '${m ~/ 60}h ${m % 60}min';
  }

  String _formatDistance(double mts) {
    return mts < 1000 ? '${mts.round()} m' : '${(mts / 1000).toStringAsFixed(1)} km';
  }
}

class _TransportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TemaColors temaColors;

  const _TransportButton({
    required this.icon, required this.label, required this.isActive,
    required this.onTap, required this.temaColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? temaColors.secondary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? temaColors.secondary : Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? temaColors.secondary : Colors.white54),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isActive ? temaColors.secondary : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}