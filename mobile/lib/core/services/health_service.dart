// mobile/lib/core/services/health_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HealthService {
  // Note: We use the base domain here, not the /api/v1 prefix,
  // because our FastAPI /health route is at the root level.
  static const String _backendUrl = 'https://tuklascope-api.onrender.com';

  static Future<bool> pingBackend() async {
    try {
      debugPrint('📡 Pinging Tuklascope Backend...');

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
