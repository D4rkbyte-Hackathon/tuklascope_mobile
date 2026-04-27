// mobile/lib/core/services/chat_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../network/api_client.dart';

class ChatService {
  static Future<String?> sendMessage({
    required String objectName,
    required String strand,
    required String cardContent,
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final payload = {
        "object_name": objectName,
        "strand": strand,
        "card_content": cardContent,
        "message": message,
        "history": history,
      };

      final response = await ApiClient.post(ApiConfig.chatAsk, body: payload);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'];
      } else {
        debugPrint('❌ Chat API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Chat API Exception: $e');
      return null;
    }
  }
}
