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
        debugPrint('🎯 AI DECK RESPONSE: ${response.body}');
        return jsonDecode(response.body);
      } else {
        // 🚀 FIX: Extract the specific error message from the backend
        String errorMessage = 'An unknown error occurred.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['detail'] != null) {
            errorMessage = errorBody['detail'];
          }
        } catch (_) {} // If body isn't JSON, fallback to default

        debugPrint('Learn API Error: ${response.statusCode} - $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Learn API Exception: $e');
      rethrow; // Pass the error up to the UI
    }
  }
}
