import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testadm/sugggestion/PrefsHelper.dart';
import 'star_model.dart';

class StarService {
  final String baseUrl = "https://astro-j7b4.onrender.com/api/admins/star";

  /// Get headers including latest token
  Future<Map<String, String>> _getHeaders() async {
    final token = await PrefsHelper.getToken();
    print("[StarService] Using token: $token"); // ✅ Print token
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fetch all star posts
  Future<List<StarPost>> fetchAllPosts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts: ${response.body}');
    }
  }

  // Create a new star post
  Future<void> createPost(int starId, String description, String type) async {
    final headers = await _getHeaders();
    final body = json.encode({
      'starId': starId,
      'description': description,
      'type': type,
    });

    print("[StarService] Creating Star post with body: $body");

    final response = await http.post(
      Uri.parse("$baseUrl/"),
      headers: headers,
      body: body,
    );

    print("[StarService] Status: ${response.statusCode}");
    print("[StarService] Response: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create Star post: ${response.body}');
    }
  }

  // Update a star post
  Future<void> updatePost(int postId, String description, int starId) async {
    final headers = await _getHeaders();
    final body = json.encode({"content": description, "starId": starId});
    print("[StarService] Updating postId: $postId with body: $body");

    final response = await http.put(
      Uri.parse("$baseUrl/$postId"),
      headers: headers,
      body: body,
    );

    print("[StarService] Update response: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception('Failed to update post: ${response.body}');
    }
  }

  // Delete a star post
  Future<void> deletePost(int postId) async {
    final headers = await _getHeaders();
    print("[StarService] Deleting postId: $postId");

    final response = await http.delete(
      Uri.parse("$baseUrl/$postId"),
      headers: headers,
    );

    print("[StarService] Delete response: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }
}
