// lib/features/map/presentation/map_screen.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/tema_provider.dart';
import '../data/route_service.dart';
import '../domain/models/poi_model.dart';
import 'providers/map_provider.dart';
import 'widgets/map_controls.dart';
import 'widgets/poi_bottom_sheet.dart';
import 'widgets/route_panel.dart';
import 'widgets/itinerary_panel.dart';

// ── Paleta semántica ──────────────────────────────────────────────────────────
const _kSurfaceLowest  = Color(0xFF0E0E10);
const _kSurfaceLow     = Color(0xFF1B1B1D);
const _kSurface        = Color(0xFF201F21);
const _kSurfaceHigh    = Color(0xFF2A2A2C);
const _kSurfaceHighest = Color(0xFF353437);
const _kOnSurfaceVar   = Color(0xFF8A8A8E);
const _kSecondary      = Color(0xFF98D5A2);
const _kOnSecondary    = Color(0xFF003918);
const _kPrimaryContainer = Color(0xFF273D6C);
const _kOutlineVariant = Color(0xFF44464F);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  PointAnnotationManager?    _annotationManager;
  PolylineAnnotationManager? _polylineManager;
  final Map<String, Uint8List> _iconCache = {};

  int _navIndex = 1; // 1 = Mapa
  bool _panelMinimizado = false;

  @override
  Widget build(BuildContext context) {
    final mapState   = ref.watch(mapProvider);
    final temaColors = ref.watch(temaColoresProvider);
    final s          = mapState.value;

    // Escuchar cambios de estado para redibujar
    ref.listen(mapProvider, (prev, next) {
      final ns = next.value;
      if (ns == null) return;
      if (prev?.value?.itinerario != ns.itinerario || prev?.value?.rutasAlternativas != ns.rutasAlternativas) {
        if (_panelMinimizado) setState(() => _panelMinimizado = false);
      }
      _dibujarPois(ns.poisFiltrados, temaColors);
      if (ns.rutasAlternativas.isNotEmpty) {
        _dibujarRutas(ns.rutasAlternativas, ns.rutaActivaIndex, temaColors);
      } else if (ns.itinerarioCoords.isNotEmpty) {
        _dibujarRutaItinerario(ns.itinerarioCoords, temaColors);
      } else if (ns.rutasAlternativas.isEmpty && ns.itinerarioCoords.isEmpty) {
        _polylineManager?.deleteAll();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final hayPanel = (s?.rutasAlternativas.isNotEmpty ?? false) || (s?.itinerario != null);
        if (hayPanel) {
          ref.read(mapProvider.notifier).limpiarRutas();
          _polylineManager?.deleteAll();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: _kSurfaceLowest,
        // STACK: El mapa al fondo, la UI flotando encima
        body: Stack(
          children: [
            // ── 1. MAPA (Fondo absoluto) ─────────────────────────────────────
            Positioned.fill(
              child: MapWidget(
                key: const ValueKey('muul_map'),
                styleUri: AppConstants.mapboxStyleDark,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-99.1332, 19.4326)),
                  zoom: 13.0,
                ),
                onMapCreated: (MapboxMap controller) async {
                  _annotationManager = await controller.annotations.createPointAnnotationManager();
                  _polylineManager = await controller.annotations.createPolylineAnnotationManager();
                  _annotationManager!.addOnPointAnnotationClickListener(
                    _PoiClickListener(ref: ref, context: context),
                  );

                  await controller.location.updateSettings(
                    LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true,
                      pulsingColor: Colors.green.value, // Aura verde
                    ),
                  );

                  ref.read(mapProvider.notifier).onMapCreated(controller);
                },
                onStyleLoadedListener: (_) => debugPrint('🗺️ dark-v11 cargado'),
              ),
            ),

            // ── 2. HEADER FLOTANTE (Buscador y Filtros) ──────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _SearchBarFlotante(ref: ref),
                  const SizedBox(height: 12),
                  _FiltrosHorizontales(mapState: s, temaColors: temaColors, ref: ref),
                ],
              ),
            ),

            // ── 3. CONTROLES DEL MAPA FLOTANTES (Derecha) ────────────────────
            Positioned(
              right: 16,
              bottom: 190,
              child: _MapControlsSquare(temaColors: temaColors),
            ),

            // ── 4. BOTÓN FLOTANTE MUUL AI (Global) ───────────────────────────
            Positioned(
              bottom: (s?.poisParaItinerario.isNotEmpty ?? false) ? 140 : 16, 
              left: 16,
              child: FloatingActionButton.extended(
                heroTag: 'muul_ai_fab',
                backgroundColor: _kSurfaceHighest,
                elevation: 6,
                icon: Icon(Icons.auto_awesome, color: temaColors.primary, size: 20),
                label: Text(
                  'Muul AI', 
                  style: TextStyle(color: temaColors.primary, fontWeight: FontWeight.bold)
                ),
                onPressed: () {
                  // TODO: Navegar a la pantalla del chat
                  debugPrint("Abriendo chat Muul AI...");
                },
              ),
            ),

            // ── 5. PANELES INFERIORES FLOTANTES (Minimizables) ───────────────
            
            // Si el usuario lo deslizó hacia abajo, mostramos el botón de restaurar
            if (_panelMinimizado && ((s?.rutasAlternativas.isNotEmpty ?? false) || s?.itinerario != null || (s?.poisParaItinerario.isNotEmpty ?? false)))
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'restore_panel',
                  backgroundColor: temaColors.secondary,
                  onPressed: () => setState(() => _panelMinimizado = false),
                  child: const Icon(Icons.menu_open, color: _kOnSecondary),
                ),
              )
            else ...[
              // Panel de Calcular Ruta (Oculto hasta seleccionar al menos 1 parada)
              if ((s?.rutasAlternativas.isEmpty ?? true) && s?.itinerario == null && (s?.poisParaItinerario.isNotEmpty ?? false))
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity! > 200) setState(() => _panelMinimizado = true);
                    },
                    child: _BottomActionCard(mapState: s, temaColors: temaColors, ref: ref),
                  ),
                ),

              // Panel de selección de rutas alternativas
              if ((s?.rutasAlternativas.isNotEmpty ?? false) && s?.itinerario == null)
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity! > 200) setState(() => _panelMinimizado = true);
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 380),
                      child: RoutePanel(
                        rutas: s!.rutasAlternativas,
                        indexActivo: s.rutaActivaIndex,
                        onSelectRuta: (i) => ref.read(mapProvider.notifier).cambiarRutaActiva(i),
                        onClose: () {
                          ref.read(mapProvider.notifier).limpiarRutas();
                          _polylineManager?.deleteAll();
                        },
                        temaColors: temaColors,
                      ),
                    ),
                  ),
                ),

              // Panel de Itinerario activo
              if (s?.itinerario != null)
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity! > 200) setState(() => _panelMinimizado = true);
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 380),
                      child: ItineraryPanel(
                        itinerario: s!.itinerario!,
                        onClose: () {
                          ref.read(mapProvider.notifier).limpiarRutas();
                          _polylineManager?.deleteAll();
                        },
                        temaColors: temaColors,
                      ),
                    ),
                  ),
                ),
            ],

            // ── 5. OVERLAYS DE CARGA ─────────────────────────────────────────
            if (s?.isLoadingPois ?? false)
              Positioned(
                top: 130, left: 0, right: 0,
                child: Center(child: _LoadingChip(texto: 'Buscando lugares…')),
              ),
            if (s?.isLoadingRuta ?? false)
              const Center(child: _LoadingChip(texto: 'Calculando ruta…')),
          ],
        ),
      ),
    );
  }

  // ── Lógica Original del Mapa Mantenida Intacta ──────────────────────────────

  Future<Uint8List> _generarIcono(Color color, String emoji) async {
    final key = '${color.value}_$emoji';
    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    const size = 56.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, glowPaint);

    final bgPaint = Paint()..color = _kSurface;
    canvas.drawCircle(const Offset(size / 2, size / 2), 22, bgPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(size / 2, size / 2), 22, borderPaint);

    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(text: emoji, style: const TextStyle(fontSize: 22))
      ..layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final result = bytes!.buffer.asUint8List();
    _iconCache[key] = result;
    return result;
  }

  static Color _colorParaCategoria(String cat) {
    switch (cat.toLowerCase()) {
      case 'restaurant': case 'comida': case 'food': return const Color(0xFFE53935);
      case 'museum': case 'cultura': case 'arte': case 'historic': return const Color(0xFF8E24AA);
      case 'market': case 'tienda': case 'shop': return const Color(0xFF1E88E5);
      case 'park': return const Color(0xFF43A047);
      case 'cafe': return const Color(0xFF6D4C41);
      case 'deportes': case 'sports': return const Color(0xFFE65100);
      default: return _kSecondary;
    }
  }

  static String _emojiParaCategoria(String cat) {
    switch (cat.toLowerCase()) {
      case 'restaurant': case 'comida': case 'food': return '🌮';
      case 'museum': case 'cultura': case 'arte': case 'historic': return '🏛️';
      case 'market': case 'tienda': case 'shop': return '🛍️';
      case 'park': return '🌳';
      case 'cafe': return '☕';
      case 'deportes': case 'sports': return '🏟️';
      default: return '📍';
    }
  }

  Future<void> _dibujarPois(List<PoiModel> pois, TemaColors temaColors) async {
    if (_annotationManager == null) return;
    await _annotationManager!.deleteAll();

    for (final poi in pois) {
      final color  = _colorParaCategoria(poi.categoria);
      final emoji  = _emojiParaCategoria(poi.categoria);
      final imagen = await _generarIcono(color, emoji);

      await _annotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(poi.longitud, poi.latitud)),
          image: imagen,
          iconSize: poi.verificado ? 1.15 : 0.95,
          iconAnchor: IconAnchor.BOTTOM,
          textField: poi.nombre,
          textSize: 10,
          textColor: Colors.white.value,
          textHaloColor: Colors.black.value,
          textHaloWidth: 1.5,
          textOffset: [0, 0.4],
          textAnchor: TextAnchor.TOP,
        ),
      );
    }
  }

  Future<void> _dibujarRutas(List<RouteResult> rutas, int indexActivo, TemaColors temaColors) async {
    if (_polylineManager == null) return;
    await _polylineManager!.deleteAll();

    for (var i = 0; i < rutas.length; i++) {
      final esActiva = i == indexActivo;
      final coords = rutas[i].coordenadas.map((c) => Position(c[0], c[1])).toList();

      if (esActiva) {
        await _polylineManager!.create(PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: temaColors.secondary.withValues(alpha: 0.30).value,
          lineWidth: 14.0, lineBlur: 8.0,
        ));
        await _polylineManager!.create(PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: temaColors.secondary.value,
          lineWidth: 4.0,
        ));
      } else {
        await _polylineManager!.create(PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: Colors.grey.withValues(alpha: 0.30).value,
          lineWidth: 2.5,
        ));
      }
    }
  }

  Future<void> _dibujarRutaItinerario(List<List<double>> coords, TemaColors temaColors) async {
    if (_polylineManager == null) return;
    await _polylineManager!.deleteAll();
    final positions = coords.map((c) => Position(c[0], c[1])).toList();

    await _polylineManager!.create(PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: temaColors.secondary.withValues(alpha: 0.30).value,
      lineWidth: 14.0, lineBlur: 8.0,
    ));
    await _polylineManager!.create(PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: temaColors.secondary.value,
      lineWidth: 4.0,
    ));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// NUEVOS COMPONENTES FLOTANTES MÓVILES (Reemplazan la UI de Escritorio)
// ════════════════════════════════════════════════════════════════════════════

class _SearchBarFlotante extends StatelessWidget {
  final WidgetRef ref;
  const _SearchBarFlotante({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _kSurfaceHighest.withValues(alpha: 0.95), // Translúcido
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Buscar en el mapa…',
          hintStyle: TextStyle(color: _kOnSurfaceVar, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: _kOnSurfaceVar),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (q) => ref.read(mapProvider.notifier).buscar(q),
      ),
    );
  }
}

class _FiltrosHorizontales extends StatelessWidget {
  final MapState? mapState;
  final TemaColors temaColors;
  final WidgetRef ref;

  const _FiltrosHorizontales({required this.mapState, required this.temaColors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final categoria = mapState?.categoriaActiva ?? '';
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _FilterChip(
            label: 'Todos', emoji: '🗺️', active: categoria.isEmpty, temaColors: temaColors,
            onTap: () => ref.read(mapProvider.notifier).filtrarPorCategoria(''),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Comida', emoji: '🍜', active: categoria == 'comida', temaColors: temaColors,
            onTap: () => ref.read(mapProvider.notifier).filtrarPorCategoria('comida'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Cultural', emoji: '🏛️', active: categoria == 'cultura', temaColors: temaColors,
            onTap: () => ref.read(mapProvider.notifier).filtrarPorCategoria('cultura'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Tiendas', emoji: '🛍️', active: categoria == 'tienda', temaColors: temaColors,
            onTap: () => ref.read(mapProvider.notifier).filtrarPorCategoria('tienda'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool active;
  final TemaColors temaColors;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label, required this.emoji, required this.active,
    required this.temaColors, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? temaColors.secondary : _kSurfaceHighest.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? _kOnSecondary : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Text(emoji, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _BottomActionCard extends StatelessWidget {
  final MapState? mapState;
  final TemaColors temaColors;
  final WidgetRef ref;

  const _BottomActionCard({required this.mapState, required this.temaColors, required this.ref});

  @override
  Widget build(BuildContext context) {
    final nParadas = mapState?.poisParaItinerario.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurfaceLow.withValues(alpha: 0.95), // Translúcido para ver el mapa por debajo
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
        border: Border.all(color: _kOutlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info de paradas (Ya sin el botón gigante de AI)
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: temaColors.secondary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '$nParadas paradas seleccionadas',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Text(
                nParadas > 0 ? '~${nParadas * 8} min' : '',
                style: const TextStyle(color: _kOnSurfaceVar, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Botón Calcular Ruta
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const ui.Size(double.infinity, 54), // ui.Size previene el error con Mapbox
              backgroundColor: temaColors.secondary,
              foregroundColor: _kOnSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: nParadas > 0 ? () => ref.read(mapProvider.notifier).calcularItinerario() : null,
            child: const Text('CALCULAR RUTA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final TemaColors temaColors;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({required this.temaColors, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kSurfaceHighest, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: _kSurfaceLowest,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: temaColors.secondary,
        unselectedItemColor: _kOnSurfaceVar,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMPONENTES ORIGINALES REUTILIZADOS
// ════════════════════════════════════════════════════════════════════════════

class _MapControlsSquare extends ConsumerWidget {
  final TemaColors temaColors;
  const _MapControlsSquare({required this.temaColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SquareButton(
          icon: Icons.add,
          onTap: () async {
            final ctrl = ref.read(mapProvider).value?.mapController;
            if (ctrl == null) return;
            final cam = await ctrl.getCameraState();
            ctrl.flyTo(
              CameraOptions(zoom: (cam.zoom + 1).clamp(0, 22)),
              MapAnimationOptions(duration: 250),
            );
          },
        ),
        const SizedBox(height: 4),
        _SquareButton(
          icon: Icons.remove,
          onTap: () async {
            final ctrl = ref.read(mapProvider).value?.mapController;
            if (ctrl == null) return;
            final cam = await ctrl.getCameraState();
            ctrl.flyTo(
              CameraOptions(zoom: (cam.zoom - 1).clamp(0, 22)),
              MapAnimationOptions(duration: 250),
            );
          },
        ),
        const SizedBox(height: 16),
        _SquareButton(
          icon: Icons.my_location,
          onTap: () => ref.read(mapProvider.notifier).fetchUserLocation(),
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _kSurfaceHighest.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _PoiClickListener extends OnPointAnnotationClickListener {
  final WidgetRef ref;
  final BuildContext context;

  _PoiClickListener({required this.ref, required this.context});

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    final pois   = ref.read(mapProvider).value?.pois ?? [];
    final coords = annotation.geometry.coordinates;

    final poi = pois.firstWhere(
      (p) => (p.longitud - coords.lng).abs() < 0.0001 && (p.latitud - coords.lat).abs() < 0.0001,
      orElse: () => PoiModel(id: '', nombre: 'Lugar', categoria: 'general', descripcion: '', latitud: coords.lat.toDouble(), longitud: coords.lng.toDouble()),
    );

    ref.read(mapProvider.notifier).seleccionarPoi(poi);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PoiBottomSheet(poi: poi),
    );
    return true;
  }
}

class _LoadingChip extends StatelessWidget {
  final String texto;
  const _LoadingChip({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kSecondary.withValues(alpha: 0.4)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_kSecondary)),
          ),
          const SizedBox(width: 8),
          Text(texto, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}