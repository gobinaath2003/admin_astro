import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testadm/model/course.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/syllabus';


  static Future<List<Course>> getCourses() async {
    try {
      print('🔍 Fetching courses from: $baseUrl');
      final response = await http.get(Uri.parse(baseUrl));
      print('📥 GET Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => Course.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load courses - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error in getCourses: $e');
      throw Exception('Error: $e');
    }
  }

  // ================= GET COURSE BY ID =================
  static Future<Course?> getCourseById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) return Course.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('❌ Error in getCourseById: $e');
      return null;
    }
  }

  // ================= CREATE COURSE =================
  static Future<bool> createCourse({
    required String title,
    String? content,
    File? videoFile,
    File? pdfFile,
    Uint8List? videoBytes,
    Uint8List? pdfBytes,
    String? videoFileName,
    String? pdfFileName,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['title'] = title;
      if (content != null) request.fields['content'] = content;

      // Video
      if (kIsWeb && videoBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'video',
          videoBytes,
          filename: videoFileName ?? 'video.mp4',
        ));
      } else if (!kIsWeb && videoFile != null && videoFile.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
      }

      
      if (kIsWeb && pdfBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdf',
          pdfBytes,
          filename: pdfFileName ?? 'document.pdf',
        ));
      } else if (!kIsWeb && pdfFile != null && pdfFile.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('pdf', pdfFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('❌ Error in createCourse: $e');
      return false;
    }
  }

  // ================= UPDATE COURSE =================
  static Future<bool> updateCourse({
    required int id,
    required String title,
    String? content,
    File? videoFile,
    File? pdfFile,
    Uint8List? videoBytes,
    Uint8List? pdfBytes,
    String? videoFileName,
    String? pdfFileName,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
      request.fields['title'] = title;
      if (content != null) request.fields['content'] = content;

      // Video
      if (kIsWeb && videoBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'video',
          videoBytes,
          filename: videoFileName ?? 'video.mp4',
        ));
      } else if (!kIsWeb && videoFile != null && videoFile.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
      }

      // PDF
      if (kIsWeb && pdfBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdf',
          pdfBytes,
          filename: pdfFileName ?? 'document.pdf',
        ));
      } else if (!kIsWeb && pdfFile != null && pdfFile.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('pdf', pdfFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Update Status: ${response.statusCode}');
      print('📄 Update Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in updateCourse: $e');
      return false;
    }
  }

  // ================= DELETE COURSE =================
  static Future<bool> deleteCourse(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      print('📥 Delete Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in deleteCourse: $e');
      return false;
    }
  }

  // ================= TEST SERVER CONNECTIVITY =================
  static Future<void> testServerConnectivity() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('🔍 Server GET Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Server connectivity failed: $e');
    }
  }
}
