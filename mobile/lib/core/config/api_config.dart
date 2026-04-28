// mobile/lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Fetch the base URL from the .env file.
  // Fallback explicitly to the Render production environment.
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Strict fallback to Render since local Docker is deprecated
    return 'https://tuklascope-api.onrender.com/api/v1';
  }

  // Specific Endpoint Routes
  static String get discoverVision => '$baseUrl/discover/vision';
  static String get discoverSave => '$baseUrl/discover/save';
  static String get generateLearnDeck => '$baseUrl/learn/generate-deck';
  static String get pathfinderAnalyze => '$baseUrl/pathfinder/recommend';
  static String get pathfinderSkills => '$baseUrl/pathfinder/skills';
  static String get chatAsk => '$baseUrl/chat';
}
