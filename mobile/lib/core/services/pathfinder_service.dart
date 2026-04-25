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
}
