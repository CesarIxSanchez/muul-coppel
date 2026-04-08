import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../src/services/muul_api_client.dart';

// ── Badge Models ───────────────────────────────────────────────────────────

class Badge {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int requisitoVisitas;
  final String? coleccionId;

  Badge({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.requisitoVisitas,
    this.coleccionId,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String? ?? 'unknown',
      nombre: json['nombre'] as String? ?? 'Sin nombre',
      descripcion: json['descripcion'] as String? ?? 'Sin descripción',
      icono: json['icono'] as String? ?? '🏅',
      requisitoVisitas: json['requisito_visitas'] as int? ?? 0,
      coleccionId: json['coleccion_id'] as String?,
    );
  }
}

class UserBadge {
  final String usuarioId;
  final String insigniaId;
  final DateTime obtenidaEn;
  final Badge insignia;

  UserBadge({
    required this.usuarioId,
    required this.insigniaId,
    required this.obtenidaEn,
    required this.insignia,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      usuarioId: json['usuario_id'] as String? ?? 'unknown',
      insigniaId: json['insignia_id'] as String? ?? 'unknown',
      obtenidaEn: DateTime.tryParse(json['obtenida_en'] as String? ?? '') ?? DateTime.now(),
      insignia: Badge.fromJson(json['insignias'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// ── Providers ───────────────────────────────────────────────────────────────

/// Provider que proporciona una instancia del cliente API
final muulApiClientProvider = Provider<MuulApiClient>((ref) {
  return MuulApiClient(AppConstants.prodApiBaseUrl);
});

/// Provider que obtiene todas las insignias disponibles (catálogo completo desde API)
final allBadgesProvider = FutureProvider<List<Badge>>((ref) async {
  final apiClient = ref.watch(muulApiClientProvider);
  
  try {
    print('🔍 Obteniendo catálogo de insignias desde API...');
    final response = await apiClient.fetchBadges();
    
    print('📊 Total de insignias en catálogo: ${response.length}');

    return response
        .map((badge) {
          try {
            return Badge.fromJson(badge as Map<String, dynamic>);
          } catch (e) {
            print('❌ Error mapeando badge: $e');
            return null;
          }
        })
        .whereType<Badge>()
        .toList();
  } catch (e) {
    print('❌ Error al cargar insignias desde API: $e');
    throw Exception('Error al cargar insignias: $e');
  }
});

/// Provider que obtiene las insignias desbloqueadas del usuario desde la API
final userBadgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final apiClient = ref.watch(muulApiClientProvider);
  final supabaseClient = Supabase.instance.client;
  final user = supabaseClient.auth.currentUser;

  if (user == null) {
    print('⚠️ Usuario no autenticado');
    throw Exception('Usuario no autenticado');
  }

  try {
    print('🔍 Obteniendo insignias del usuario desde API: ${user.id}');
    
    // Obtener insignias del usuario desde la API
    final response = await apiClient.fetchUserBadges(user.id);
    
    print('📊 Insignias encontradas para el usuario: ${response.length}');
    
    if (response.isEmpty) {
      print('⚠️ El usuario no tiene insignias desbloqueadas');
      return [];
    }

    // Mapear respuesta a UserBadge
    List<UserBadge> result = [];
    for (var item in response) {
      try {
        final userBadge = UserBadge.fromJson(item as Map<String, dynamic>);
        result.add(userBadge);
        print('✨ Insignia cargada: ${userBadge.insignia.nombre}');
      } catch (e) {
        print('❌ Error procesando insignia: $e');
        continue;
      }
    }
    
    print('🎉 Total de insignias cargadas: ${result.length}');
    return result;
  } catch (e) {
    print('❌ Error al cargar insignias del usuario: $e');
    throw Exception('Error al cargar insignias: $e');
  }
});

/// Provider que obtiene el token de acceso para hacer llamadas autenticadas
final authTokenProvider = FutureProvider<String?>((ref) async {
  final session = Supabase.instance.client.auth.currentSession;
  return session?.accessToken;
});

/// Provider que verifica y desbloquea nuevas insignias para el usuario
final checkNewBadgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final client = ref.watch(muulApiClientProvider);
  final token = await ref.watch(authTokenProvider.future);

  if (token == null) {
    throw Exception('Token de autenticación no disponible');
  }

  try {
    final result = await client.checkUserBadges(token: token);
    final newBadges = (result['nuevas'] as List<dynamic>?)
            ?.map((badge) {
              try {
                return UserBadge.fromJson(badge as Map<String, dynamic>);
              } catch (e) {
                print('Error mapeando new badge: $e');
                return null;
              }
            })
            .whereType<UserBadge>()
            .toList() ??
        [];
    return newBadges;
  } catch (e) {
    print('Error al verificar nuevas insignias: $e');
    throw Exception('Error al verificar nuevas insignias: $e');
  }
});
