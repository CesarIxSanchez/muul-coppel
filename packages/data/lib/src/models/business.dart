import 'place.dart';

class Business extends Place {
  final String? contactPhone;
  final String? website;
  final List<String>? resources;

  Business({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.category,
    required super.description,
    super.address,
    super.images,
    super.isVerified,
    this.contactPhone,
    this.website,
    this.resources,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] ?? json['name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? json['longitud']?.toString() ?? '0.0') ?? 0.0,
      category: json['categoria'] ?? json['category'] ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      address: json['direccion'] ?? json['address'],
      images: (json['imagenes'] ?? json['images']) != null ? List<String>.from(json['imagenes'] ?? json['images']) : null,
      isVerified: json['is_verified'] ?? json['verificado'] ?? false,
      contactPhone: json['telefono'] ?? json['contact_phone'],
      website: json['sitio_web'] ?? json['website'],
      resources: (json['recursos'] ?? json['resources']) != null ? List<String>.from(json['recursos'] ?? json['resources']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['contact_phone'] = contactPhone;
    json['website'] = website;
    json['resources'] = resources;
    return json;
  }
}
