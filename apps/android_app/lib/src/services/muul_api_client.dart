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
}
