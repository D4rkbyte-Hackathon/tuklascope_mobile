// mobile/lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  /// Internal method to fetch the token and build headers
  static Future<Map<String, String>> _getAuthHeaders(
    Map<String, String>? customHeaders,
  ) async {
    final headers = {'Content-Type': 'application/json'};

    // Safely retrieve the current session token from Supabase
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    // Merge any custom headers passed by the developer
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Centralized GET request wrapper
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final finalHeaders = await _getAuthHeaders(headers);
      return await http.get(Uri.parse(url), headers: finalHeaders);
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  /// Centralized POST request wrapper
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final finalHeaders = await _getAuthHeaders(headers);
      return await http.post(
        Uri.parse(url),
        headers: finalHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  /// Centralized PUT request wrapper
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final finalHeaders = await _getAuthHeaders(headers);
      return await http.put(
        Uri.parse(url),
        headers: finalHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  /// Centralized Multipart request wrapper (For Image Uploads)
  static Future<http.Response> multipartPost(
    String url, {
    required Map<String, String> fields,
    required http.MultipartFile file,
    Map<String, String>? headers,
  }) async {
    try {
      final finalHeaders = await _getAuthHeaders(headers);

      // 🚀 CRITICAL FIX: Remove the JSON content-type because this is an image upload!
      finalHeaders.remove('Content-Type');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Attach our secure headers (including the JWT token!)
      request.headers.addAll(finalHeaders);

      // Attach the form fields (like grade_level)
      request.fields.addAll(fields);

      // Attach the image
      request.files.add(file);

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Multipart network request failed: $e');
    }
  }
}
