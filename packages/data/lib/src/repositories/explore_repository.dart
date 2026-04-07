import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/business.dart';

class ExploreRepository {
  final http.Client client;
  final String baseUrl;

  ExploreRepository({
    required this.client,
    required this.baseUrl,
  });

  Future<List<Place>> fetchPois() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/pois'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) {
          // If the POI contains business specific fields you could conditionally return Business
          // For now, mapping all as Place. Or if you know the type field:
          if (json.containsKey('resources') || json.containsKey('contact_phone')) {
            return Business.fromJson(json);
          }
          return Place.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load pois (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
