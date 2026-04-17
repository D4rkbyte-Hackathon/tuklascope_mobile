// mobile/lib/core/services/discovery_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../config/api_config.dart';
import '../network/api_client.dart';

class DiscoveryService {
  /// Takes an image file, compresses it, sends it securely to the FastAPI backend, and returns the AI's analysis.
  static Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      debugPrint('🚀 Initiating Secure Uplink: Preparing image...');

      // --- 1. COMPRESS THE IMAGE ---
      // Get a temporary directory to store the compressed file
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress the image to a max width/height of 1024px and 70% quality.
      // This usually turns a 10MB photo into a ~400KB photo perfectly fine for AI.
      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: 70,
            minWidth: 1024,
            minHeight: 1024,
          );

      // Fallback to original if compression fails for some reason
      final File fileToUpload = compressedXFile != null
          ? File(compressedXFile.path)
          : imageFile;

      final originalSize = (await imageFile.length()) / (1024 * 1024);
      final newSize = (await fileToUpload.length()) / (1024 * 1024);
      debugPrint(
        '📸 Compression complete: ${originalSize.toStringAsFixed(2)}MB -> ${newSize.toStringAsFixed(2)}MB',
      );

      // --- 2. UPLOAD THE COMPRESSED IMAGE ---
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        fileToUpload.path,
        contentType: MediaType('image', 'jpeg'),
      );

      final response = await ApiClient.multipartPost(
        ApiConfig.discoverVision,
        fields: {
          'grade_level': 'JHS (Grades 7-10)', // Dynamic via user profile later
        },
        file: multipartFile,
      );

      // --- 3. HANDLE THE RESULT ---
      if (response.statusCode == 200) {
        debugPrint('✅ AI Analysis Complete!');
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint(
          '❌ Backend rejected the image. Status: ${response.statusCode}',
        );
        debugPrint('Error details: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 CRITICAL FAILURE: Image upload crashed. Error: $e');
      return null;
    }
  }
}
