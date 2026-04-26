import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanService {
  /// Fetches the current user's scan history from Supabase
  static Future<List<Map<String, dynamic>>> getUserScanHistory({
    int limit = 50,
  }) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return [];
      }

      final response = await Supabase.instance.client
          .from('scans')
          .select('id, object_name, chosen_lens, image_url, created_at, xp_awarded')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(limit);

      // response is guaranteed to be a List, so we can safely cast and return it
      debugPrint('✅ Fetched ${response.length} scans');
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      debugPrint('🚨 Error fetching scan history: $e');
      return [];
    }
  }

  /// Fetches scan history with optional filters
  static Future<List<Map<String, dynamic>>> getScanHistoryByLens({
    required String lens,
    int limit = 50,
  }) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return [];
      }

      final response = await Supabase.instance.client
          .from('scans')
          .select('id, object_name, chosen_lens, image_url, created_at, xp_awarded')
          .eq('user_id', currentUser.id)
          .eq('chosen_lens', lens)
          .order('created_at', ascending: false)
          .limit(limit);

      // response is guaranteed to be a List, so we can safely cast and return it
      debugPrint('✅ Fetched ${response.length} scans for lens: $lens');
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      debugPrint('🚨 Error fetching scans by lens: $e');
      return [];
    }
  }

  /// Fetches a specific scan by ID with all details
  static Future<Map<String, dynamic>?> getScanById(String scanId) async {
    try {
      final response = await Supabase.instance.client
          .from('scans')
          .select('*')
          .eq('id', scanId)
          .maybeSingle();

      // We KEEP this check because .maybeSingle() CAN return null 
      if (response != null) {
        debugPrint('✅ Fetched scan: $scanId');
        return response;
      } else {
        debugPrint('⚠️ Scan not found: $scanId');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Error fetching scan: $e');
      return null;
    }
  }
}