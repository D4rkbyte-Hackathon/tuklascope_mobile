// mobile/lib/core/config/api_config.dart

class ApiConfig {
  // Use the local IP if you are testing the backend locally (e.g., 192.168.x.x:8000)
  // Currently, it is pointing directly to our live Render staging environment.
  static const String baseUrl = 'https://tuklascope-api.onrender.com/api/v1';

  // Specific Endpoint Routes
  static const String discoverVision = '$baseUrl/discover/vision';
  static const String generateLearnDeck = '$baseUrl/learn/generate';
  static const String pathfinderAnalyze = '$baseUrl/pathfinder/analyze';
}
