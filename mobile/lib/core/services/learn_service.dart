import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../config/api_config.dart';

class LearnService {
  static Future<Map<String, dynamic>?> generateDeck({
    required String objectName,
    required String gradeLevel,
    required String selectedLens,
    required String teaserContext,
  }) async {
    try {
      // 🚀 FIX: Removed the hardcoded path and reverted to your exact ApiConfig constant
      final response = await ApiClient.post(
        ApiConfig.generateLearnDeck,
        body: {
          'object_name': objectName,
          'grade_level': gradeLevel,
          'chosen_lens': selectedLens,
          'teaser_context': teaserContext,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint(
          'Learn API Error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Learn API Exception: $e');
      return null;
    }
  }
}
