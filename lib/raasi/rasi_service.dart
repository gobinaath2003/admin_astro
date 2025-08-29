import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'rasi_model.dart';

class RasiService {
  static const String baseUrl =
      'https://astro-j7b4.onrender.com/api/admins/raasi';
  static const String loginUrl =
      'https://astro-j7b4.onrender.com/api/admins/login';

  /// Admin Login → returns {token, adminId}
  static Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    print("Logging in admin: $email");
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print("Login response status: ${response.statusCode}");
    print("Login response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'token': data['token']};
    } else {
      throw Exception('Admin login failed: ${response.body}');
    }
  }

  /// Fetch all Rasi posts
  /// Fetch Rasi posts by adminId
  static Future<List<RasiModel>> fetchRasiPostsByAdmin(
    String token,
    int adminId,
  ) async {
    final url =
        'https://astro-j7b4.onrender.com/api/admins/raasi/admin/adminId';
    print("Fetching Rasi posts for admin $adminId with token: $token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Fetch Rasi Posts status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RasiModel.fromJson(json)).toList();
    }

    throw Exception('Failed to fetch Rasi posts: ${response.body}');
  }

  /// Add a new Rasi post
  static Future<void> addRasiPost(
    String token,
    int raasiId,
    String content,
    int adminId, {
    String type = 'Negative',
  }) async {
    final body = json.encode({
      'raasiId': raasiId,
      'content': content,
      'adminId': adminId,
      'type': type,
    });

    print("Adding Rasi post with body: $body");
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print("Add Rasi Post status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add Rasi post: ${response.body}');
    }
  }

  /// Update existing Rasi post
  static Future<void> updateRasiPost(
    String token,
    int postId,
    String content,
    int raasiId, {
    String? type,
  }) async {
    final body = {'content': content, 'raasiId': raasiId};
    if (type != null) body['type'] = type;

    print("Updating Rasi post $postId with body: $body");
    final response = await http.put(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    print("Update Rasi Post status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to update Rasi post: ${response.body}');
    }
  }

  /// Delete Rasi post
  static Future<void> deleteRasiPost(String token, int postId) async {
    print("Deleting Rasi post $postId with token: $token");
    final response = await http.delete(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Delete Rasi Post status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Rasi post: ${response.body}');
    }
  }
}
