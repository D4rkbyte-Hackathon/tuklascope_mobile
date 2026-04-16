// mobile/lib/core/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Fetch the base URL from the .env file.
  // We provide a fallback to localhost (10.0.2.2 for Android Emulator)
  // to prevent hard crashes if the .env variable is missing.
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/v1';

  // Specific Endpoint Routes
  static String get discoverVision => '$baseUrl/discover/vision';
  static String get generateLearnDeck => '$baseUrl/learn/generate-deck';
  static String get pathfinderAnalyze => '$baseUrl/pathfinder/analyze';
}
