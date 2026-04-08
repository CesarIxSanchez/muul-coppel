import 'dart:convert';

import 'package:http/http.dart' as http;

class MuulApiClient {
  MuulApiClient(this.baseUrl);

  final String baseUrl;

  Future<bool> checkHealth() async {
    final uri = Uri.parse(baseUrl.replaceFirst('/api/v1', '/health'));
    final response = await http.get(uri);
    return response.statusCode == 200;
  }

  Future<List<dynamic>> fetchPois({String? token}) async {
    final uri = Uri.parse('$baseUrl/pois');
    final response = await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 400) {
      throw Exception('Error API /pois: ${response.statusCode}');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// Obtener catálogo completo de insignias (público)
  Future<List<dynamic>> fetchBadges() async {
    final uri = Uri.parse('$baseUrl/insignias');
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Error API /insignias: ${response.statusCode}');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// Obtener insignias desbloqueadas para un usuario específico (público)
  Future<List<dynamic>> fetchUserBadges(String userId) async {
    final uri = Uri.parse('$baseUrl/insignias/usuario/$userId');
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Error API /insignias/usuario/$userId: ${response.statusCode}');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// Verificar y desbloquear insignias para el usuario autenticado
  Future<Map<String, dynamic>> checkUserBadges({required String token}) async {
    final uri = Uri.parse('$baseUrl/insignias/check');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode >= 400) {
      throw Exception('Error API /insignias/check: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
