// mobile/lib/core/services/discovery_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';
import '../network/api_client.dart';

class DiscoveryService {
  /// Takes an image file, compresses it, sends it securely to FastAPI, and returns AI analysis.
  static Future<Map<String, dynamic>?> analyzeImage({
    required File imageFile,
    String gradeLevel =
        'JHS (Grades 7-10)', // Safe default to prevent 422 errors
  }) async {
    try {
      debugPrint('🚀 Initiating Secure Uplink: Preparing image...');

      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: 70,
            minWidth: 1024,
            minHeight: 1024,
          );

      final File fileToUpload = compressedXFile != null
          ? File(compressedXFile.path)
          : imageFile;

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        fileToUpload.path,
        contentType: MediaType('image', 'jpeg'),
      );

      final response = await ApiClient.multipartPost(
        ApiConfig.discoverVision,
        fields: {'grade_level': gradeLevel},
        file: multipartFile,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ AI Analysis Complete!');
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint(
          '❌ Vision API Error [${response.statusCode}]: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('🚨 CRITICAL FAILURE: Image upload crashed. Error: $e');
      return null;
    }
  }

  /// Uploads image to Supabase, then saves the full scan to the Render backend.
  static Future<bool> saveDiscovery({
    required String objectName,
    required String chosenLens,
    required String imagePath,
    required Map<String, dynamic> learningDeck,
    required int xpAwarded, // 🚀 FIX: Now demands the XP parameter
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint("🚨 Cannot save: User is not logged in.");
        return false;
      }

      final userId = session.user.id;
      debugPrint("☁️ Uploading image to Supabase Storage...");

      final file = File(imagePath);
      final fileBytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$userId/$fileName';

      // 1. Upload to Supabase 'scans' bucket
      await Supabase.instance.client.storage
          .from('scans')
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // 2. Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from('scans')
          .getPublicUrl(storagePath);

      debugPrint("✅ Image uploaded: $publicUrl");

      // 3. Send to Render Backend using our centralized secure ApiClient
      final payload = {
        'object_name': objectName,
        'chosen_lens': chosenLens,
        'image_url': publicUrl,
        'learning_deck': learningDeck,
        'xp_awarded': xpAwarded, // 🚀 FIX: Uses the passed parameter
        'is_aligned_with_compass': false,
      };

      final response = await ApiClient.post(
        ApiConfig.discoverSave,
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Progress successfully saved to backend!");
        return true;
      } else {
        debugPrint("🚨 Failed to save progress to backend: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🚨 Error saving discovery: $e");
      return false;
    }
  }
}
