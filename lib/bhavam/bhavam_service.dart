import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bhavam_model.dart';

class BhavamService {
  static const String baseUrl = "https://astro-j7b4.onrender.com/api/admins";

  static Future<List<BhavamModel>> fetchAllSins(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sin'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BhavamModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch sins');
    }
  }

  static Future<BhavamModel> createSin(
    String token,
    int sinId,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'sinId': sinId, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BhavamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create sin');
    }
  }

  static Future<void> updateSin(
    String token,
    int postId,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sin/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'description': description}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sin');
    }
  }

  static Future<void> deleteSin(String token, int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sin/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete sin');
    }
  }

  static Future<List<BhavamModel>> fetchSinsBySinId(
    String token,
    int sinId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sin/sin/$sinId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BhavamModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch sins by sinId');
    }
  }
}
