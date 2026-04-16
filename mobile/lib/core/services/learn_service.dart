// mobile/lib/core/services/learn_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tuklascope_mobile/core/config/api_config.dart';

class LearnService {
  /// Generates a full Discovery Card / Learning Deck based on the user's choice.
  static Future<Map<String, dynamic>?> generateDeck({
    required String objectName,
    required String gradeLevel,
    required String selectedLens,
  }) async {
    try {
      debugPrint(
        '📚 Requesting $selectedLens Learning Deck for $objectName...',
      );

      // --- NEW: FETCH THE AUTH TOKEN ---
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      if (token == null) {
        debugPrint('🚨 ERROR: No active session. User is not logged in.');
        return null;
      }
      // ---------------------------------

      // We send a POST request with a standard JSON body
      final response = await http.post(
        Uri.parse(ApiConfig.generateLearnDeck),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // NEW: The VIP Pass for FastAPI!
        },
        body: jsonEncode({
          'object_name': objectName,
          'grade_level': gradeLevel,
          'chosen_lens': selectedLens,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Learning Deck Generated!');
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('❌ Backend error. Status: ${response.statusCode}');
        debugPrint('Error details: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint(
        '🚨 CRITICAL FAILURE: Could not fetch learning deck. Error: $e',
      );
      return null;
    }
  }
}
