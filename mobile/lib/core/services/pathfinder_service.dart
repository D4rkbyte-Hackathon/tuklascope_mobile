// mobile/lib/core/services/pathfinder_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../network/api_client.dart';

class PathfinderService {
  /// Fetches the raw Neo4j Graph Data for the Skill Tree
  static Future<Map<String, dynamic>?> getSkillWeb() async {
    try {
      final response = await ApiClient.get(ApiConfig.pathfinderSkills);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('❌ Failed to fetch Neo4j Skill Web: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Neo4j Fetch Error: $e');
      return null;
    }
  }

  /// Triggers the LLM to analyze the Neo4j Skill Web and return Career Paths
  static Future<Map<String, dynamic>?> analyzePaths() async {
    try {
      // Note: We use GET or POST depending on your backend router.
      // Assuming GET since we are extracting data based on the auth token.
      final response = await ApiClient.get(ApiConfig.pathfinderAnalyze);

      if (response.statusCode == 200) {
        debugPrint('✅ Pathfinder AI Analysis Complete!');
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint(
          '❌ Backend rejected Pathfinder analysis. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('🚨 CRITICAL FAILURE: Pathfinder analyze crashed. Error: $e');
      return null;
    }
  }
}
