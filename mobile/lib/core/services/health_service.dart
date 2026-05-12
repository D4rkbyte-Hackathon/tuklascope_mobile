// mobile/lib/core/services/health_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class HealthService {
  // Dynamically get the root URL by stripping '/api/v1' from the baseUrl
  static String get _backendUrl {
    return ApiConfig.baseUrl.replaceAll('/api/v1', '');
  }

  static Future<bool> pingBackend() async {
    try {
      debugPrint('📡 Pinging Tuklascope Backend at $_backendUrl...');

      final response = await http.get(Uri.parse('$_backendUrl/health'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ SYSTEM GREEN: ${data['message']}');
        return true;
      } else {
        debugPrint(
          '❌ SYSTEM RED: Backend returned status ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('🚨 CRITICAL FAILURE: Could not reach backend. Error: $e');
      return false;
    }
  }
}
