// lib/features/map/domain/models/poi_model.dart

class PoiModel {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final double latitud;
  final double longitud;
  final bool esNegocio;
  final String? horario;
  final String? foto;
  final bool verificado;
  bool seleccionado;

  PoiModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.esNegocio = false,
    this.horario,
    this.foto,
    this.verificado = false,
    this.seleccionado = false,
  });

  factory PoiModel.fromMapbox(Map<String, dynamic> json) {
    final coords = json['geometry']['coordinates'] as List;
    final props = json['properties'] as Map<String, dynamic>;
    return PoiModel(
      id: json['id'] ?? props['mapbox_id'] ?? '',
      nombre: props['name'] ?? 'Sin nombre',
      categoria: props['poi_category']?[0] ?? 'general',
      descripcion: props['full_address'] ?? props['place_formatted'] ?? '',
      latitud: (coords[1] as num).toDouble(),
      longitud: (coords[0] as num).toDouble(),
      esNegocio: false,
    );
  }

  factory PoiModel.fromSupabase(Map<String, dynamic> json, {bool esNegocio = false}) {
      return PoiModel(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre'] ?? '',
        // Asignamos un tipo por defecto si la vista no trae el nombre de la colección
        categoria: json['categoria'] ?? (esNegocio ? 'tienda' : 'cultura'),
        // Los negocios tienen 'descripcion', los POIs usan 'contexto_ia' en tu BD
        descripcion: json['descripcion'] ?? json['contexto_ia'] ?? '',
        latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
        longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
        esNegocio: esNegocio,
        // Solo los negocios pueden tener el sello "Muul" (verificado)
        verificado: esNegocio ? (json['verificado'] ?? false) : false,
      );
    }
}