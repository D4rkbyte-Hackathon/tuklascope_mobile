// mobile/lib/core/services/discovery_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../network/api_client.dart'; // 🚀 Import our secure client

class DiscoveryService {
  /// Takes an image file, sends it securely to the FastAPI backend, and returns the AI's analysis.
  static Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      debugPrint(
        '🚀 Initiating Secure Uplink: Sending image to Tuklascope AI...',
      );

      // 1. Prepare the image file for upload
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );

      // 2. Use our secure ApiClient! It automatically attaches the Supabase JWT.
      final response = await ApiClient.multipartPost(
        ApiConfig.discoverVision,
        fields: {
          // TODO: Eventually pull this dynamically from the user's profile
          'grade_level': 'JHS (Grades 7-10)',
        },
        file: multipartFile,
      );

      // 3. Handle the Result
      if (response.statusCode == 200) {
        debugPrint('AI Analysis Complete!');
        // Ensure UTF-8 decoding so Filipino characters don't break
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint(
          'Backend rejected the image. Status: ${response.statusCode}',
        );
        debugPrint('Error details: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('CRITICAL FAILURE: Image upload crashed. Error: $e');
      return null;
    }
  }
}
