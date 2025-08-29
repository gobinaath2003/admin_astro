import 'dart:convert';
import 'package:http/http.dart' as http;
import 'laknam_model.dart';
import '../sugggestion/PrefsHelper.dart'; // token helper

class LaknamService {
  final String baseUrl = "https://astro-j7b4.onrender.com/api/admins/laknam";

  Future<Map<String, String>> _getHeaders() async {
    final token = await PrefsHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch posts created by the logged-in admin (using bearer token)
  Future<List<LaknamPost>> fetchPostsByAdmin() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/admin/adminId"), // backend finds admin from token
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => LaknamPost.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch admin posts: ${response.body}');
    }
  }


  Future<List<LaknamPost>> fetchPostsByLaknam(int laknamId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/laknam/$laknamId"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => LaknamPost.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch posts: ${response.body}');
    }
  }

  Future<void> createPost(int laknamId, String content, String type) async {
    final headers = await _getHeaders();
    final body = json.encode({
      "LaknamId": laknamId,
      "content": content,
      "type": type,
    });
    final response = await http.post(
      Uri.parse("$baseUrl/"),
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create post: ${response.body}');
    }
  }

  Future<void> updatePost(int postId, String content, int laknamId) async {
    final headers = await _getHeaders();
    final body = json.encode({"content": content, "LaknamId": laknamId});
    final response = await http.put(
      Uri.parse("$baseUrl/$postId"),
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update post: ${response.body}');
    }
  }

  Future<void> deletePost(int postId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$postId"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }
}
