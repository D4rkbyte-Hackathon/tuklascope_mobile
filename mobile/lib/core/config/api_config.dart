// mobile/lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Updated fallback to Hugging Face
    return 'https://d4rkbyte-tuklascope-api.hf.space/api/v1';
  }

  // Existing Endpoints
  static String get discoverVision => '$baseUrl/discover/vision';
  static String get discoverSave => '$baseUrl/discover/save';
  static String get generateLearnDeck => '$baseUrl/learn/generate-deck';
  static String get pathfinderAnalyze => '$baseUrl/pathfinder/recommend';
  static String get pathfinderSkills => '$baseUrl/pathfinder/skills';
  static String get chatAsk => '$baseUrl/chat';
  static String get pathwaysCatalog => '$baseUrl/pathways/catalog';
  static String enrollPathway(String id) => '$baseUrl/pathways/$id/enroll';
}
