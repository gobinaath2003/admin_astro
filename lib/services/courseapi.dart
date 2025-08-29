import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AstrologerService {
  
  static const String baseUrl =
      'http://localhost:3000/api/astrologers';

  static Future<Map<String, dynamic>> addAstrologer({
    required String name,
    required String specialization,
    required String language,
    required int experience,
    required int rating,
    required int miuutes,
    required int originalPrice,
    required int discountedPrice,
    dynamic image, 
  }) async {
    try {
      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields.addAll({
        'name': name,
        'specialization': specialization,
        'language': language,
        'experience': experience.toString(),
        'rating': rating.toString(),
        'minutes': miuutes.toString(),
        'originalPrice': originalPrice.toString(),
        'discountedPrice': discountedPrice.toString(),
      });

      // Handle image upload
      if (image != null) {
        if (kIsWeb && image is Map<String, dynamic>) {
          Uint8List bytes = image['bytes'];
          String filename = image['name'];

          // Detect mime type
          String ext = filename.split('.').last.toLowerCase();
          String mimeType = (ext == 'png')
              ? 'image/png'
              : (ext == 'jpg' || ext == 'jpeg')
                  ? 'image/jpeg'
                  : (ext == 'gif')
                      ? 'image/gif'
                      : 'application/octet-stream';

          request.files.add(http.MultipartFile.fromBytes(
            'image', // 👈 must match backend multer field name
            bytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ));
        } else if (!kIsWeb && image is File) {
          request.files.add(await http.MultipartFile.fromPath(
            'image', // 👈 must match backend multer field name
            image.path,
          ));
        }
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Astrologer added successfully',
            'data': responseData['data'],
          };
        } catch (_) {
          return {
            'success': true,
            'message': 'Astrologer added, but response not JSON',
            'raw': response.body,
          };
        }
      } else {
        try {
          var errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to add astrologer',
            'error': errorData,
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed with status ${response.statusCode}',
            'raw': response.body,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString(),
      };
    }
  }
}
