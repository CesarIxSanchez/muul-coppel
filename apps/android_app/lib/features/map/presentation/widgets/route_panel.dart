import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/tema_provider.dart';
import '../../data/route_service.dart';

class RoutePanel extends StatelessWidget {
  final List<RouteResult> rutas;
  final int indexActivo;
  final void Function(int) onSelectRuta;
  final VoidCallback onClose;
  final TemaColors temaColors;

  const RoutePanel({
    super.key,
    required this.rutas,
    required this.indexActivo,
    required this.onSelectRuta,
    required this.onClose,
    required this.temaColors,
  });

  @override
  Widget build(BuildContext context) {
    final rutaActiva = rutas[indexActivo];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: temaColors.secondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route, color: temaColors.secondary),
              const SizedBox(width: 8),
              const Text(
                'Rutas disponibles',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
          // Selector de rutas alternativas
          Row(
            children: List.generate(rutas.length, (i) {
              final esActiva = i == indexActivo;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelectRuta(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: esActiva
                          ? temaColors.secondary.withValues(alpha: 0.2)
                          : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: esActiva ? temaColors.secondary : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ruta ${i + 1}',
                          style: TextStyle(
                            color: esActiva ? temaColors.secondary : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rutas[i].duracionTexto,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          rutas[i].distanciaTexto,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          // Instrucciones de la ruta activa
          if (rutaActiva.instrucciones.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: rutaActiva.instrucciones.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: temaColors.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(color: temaColors.secondary, fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rutaActiva.instrucciones[i],
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}