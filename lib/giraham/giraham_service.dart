import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'giraham_model.dart';

class GirahamService {
  static const String baseUrl = 'https://astro-j7b4.onrender.com/api/girahams';

  /// Fetch all Girahams
  static Future<List<GirahamModel>> fetchAllGiraham(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => GirahamModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Girahams: ${response.body}');
    }
  }

  /// Fetch Giraham by ID
  static Future<GirahamModel> fetchGirahamById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch Giraham: ${response.body}');
    }
  }

  /// Create Giraham
  static Future<GirahamModel> createGiraham(
    String token,
    int girahamId,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/giraham'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'girahamId': girahamId, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create Giraham: ${response.body}');
    }
  }

  /// Update Giraham
  static Future<GirahamModel> updateGiraham(
    String token,
    int id,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'description': description}),
    );

    if (response.statusCode == 200) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update Giraham: ${response.body}');
    }
  }

  /// Delete Giraham
  static Future<void> deleteGiraham(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Giraham: ${response.body}');
    }
  }
}
