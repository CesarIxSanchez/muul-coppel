class Place {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final String description;
  final String? address;
  final List<String>? images;
  final bool isVerified;

  Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.description,
    this.address,
    this.images,
    this.isVerified = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] ?? json['name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? json['longitud']?.toString() ?? '0.0') ?? 0.0,
      category: json['categoria'] ?? json['category'] ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      address: json['direccion'] ?? json['address'],
      images: (json['imagenes'] ?? json['images']) != null ? List<String>.from(json['imagenes'] ?? json['images']) : null,
      isVerified: json['is_verified'] ?? json['verificado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'description': description,
      'address': address,
      'images': images,
      'is_verified': isVerified,
    };
  }
}
