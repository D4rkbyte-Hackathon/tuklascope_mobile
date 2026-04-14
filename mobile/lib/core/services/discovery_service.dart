// mobile/lib/core/services/discovery_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:tuklascope_mobile/core/config/api_config.dart';

class DiscoveryService {
  /// Takes an image file, sends it to the FastAPI backend, and returns the AI's analysis.
  static Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      debugPrint('🚀 Initiating Uplink: Sending image to Tuklascope AI...');

      // 1. Prepare the Multipart Request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.discoverVision),
      );

      // FastAPI strictly requires this field so it knows how complex
      // the AI's explanation should be. Hardcoding Grade 10 for testing.
      request.fields['grade_level'] = 'JHS (Grades 7-10)';

      // 2. Attach the Image File
      // The 'file' key must exactly match the parameter name in your FastAPI endpoint:
      // @app.post("/vision") async def analyze_image(file: UploadFile = File(...))
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        // We explicitly tell the backend that this is a JPEG image."
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // 3. Send the Request and wait for the AI to process
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 4. Handle the Result
      if (response.statusCode == 200) {
        debugPrint('AI Analysis Complete!');
        // FastAPI returns the Pydantic model as a JSON string
        // Ensure UTF-8 decoding so Filipino characters (ñ, etc.) don't break
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
