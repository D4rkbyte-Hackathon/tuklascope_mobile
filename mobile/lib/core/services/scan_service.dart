import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'scan_favorites_store.dart';

class ScanService {
  static bool _coerceBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> _mergeFavoriteState(
    List<Map<String, dynamic>> scans,
    String userId,
  ) async {
    var favoriteIds = await ScanFavoritesStore.getFavoriteIds(userId);

    for (final scan in scans) {
      final id = scan['id']?.toString();
      if (id == null || id.isEmpty) continue;

      if (_coerceBool(scan['is_favorite']) && !favoriteIds.contains(id)) {
        await ScanFavoritesStore.setFavorite(
          userId: userId,
          scanId: id,
          isFavorite: true,
        );
        favoriteIds = {...favoriteIds, id};
      }
    }

    favoriteIds = await ScanFavoritesStore.getFavoriteIds(userId);

    return scans.map((scan) {
      final id = scan['id']?.toString() ?? '';
      return {...scan, 'is_favorite': favoriteIds.contains(id)};
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _queryScans({
    required String userId,
    required int limit,
    bool includeFavoriteColumn = true,
    String? lens,
  }) async {
    final columns = includeFavoriteColumn
        ? 'id, object_name, chosen_lens, image_url, created_at, xp_awarded, is_favorite'
        : 'id, object_name, chosen_lens, image_url, created_at, xp_awarded';

    var query = Supabase.instance.client
        .from('scans')
        .select(columns)
        .eq('user_id', userId);

    if (lens != null) {
      query = query.eq('chosen_lens', lens);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

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

      List<Map<String, dynamic>> scans;
      try {
        scans = await _queryScans(userId: currentUser.id, limit: limit);
      } catch (e) {
        debugPrint('⚠️ Fetch without is_favorite column: $e');
        scans = await _queryScans(
          userId: currentUser.id,
          limit: limit,
          includeFavoriteColumn: false,
        );
      }

      final merged = await _mergeFavoriteState(scans, currentUser.id);
      debugPrint('✅ Fetched ${merged.length} scans');
      return merged;
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

      List<Map<String, dynamic>> scans;
      try {
        scans = await _queryScans(
          userId: currentUser.id,
          limit: limit,
          lens: lens,
        );
      } catch (e) {
        debugPrint('⚠️ Fetch without is_favorite column: $e');
        scans = await _queryScans(
          userId: currentUser.id,
          limit: limit,
          lens: lens,
          includeFavoriteColumn: false,
        );
      }

      final merged = await _mergeFavoriteState(scans, currentUser.id);
      debugPrint('✅ Fetched ${merged.length} scans for lens: $lens');
      return merged;
    } catch (e) {
      debugPrint('🚨 Error fetching scans by lens: $e');
      return [];
    }
  }

  /// Fetches a specific scan by ID with all details
  static Future<Map<String, dynamic>?> getScanById(String scanId) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final response = await Supabase.instance.client
          .from('scans')
          .select('*')
          .eq('id', scanId)
          .maybeSingle();

      if (response != null) {
        debugPrint('✅ Fetched scan: $scanId');
        if (currentUser != null) {
          final merged = await _mergeFavoriteState([response], currentUser.id);
          return merged.first;
        }
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

  /// Toggles favorite status for a scan owned by the current user.
  static Future<bool> setScanFavorite({
    required String scanId,
    required bool isFavorite,
  }) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return false;
      }

      await ScanFavoritesStore.setFavorite(
        userId: currentUser.id,
        scanId: scanId,
        isFavorite: isFavorite,
      );

      try {
        final response = await Supabase.instance.client
            .from('scans')
            .update({'is_favorite': isFavorite})
            .eq('id', scanId)
            .eq('user_id', currentUser.id)
            .select('id');

        if (response.isEmpty) {
          debugPrint(
            '⚠️ Supabase favorite not updated (column missing or RLS). Local save kept.',
          );
        } else {
          debugPrint('✅ Scan $scanId favorite=$isFavorite synced to Supabase');
        }
      } catch (e) {
        debugPrint(
          '⚠️ Supabase favorite sync failed (local save kept): $e',
        );
      }

      return true;
    } catch (e) {
      debugPrint('🚨 Error updating scan favorite: $e');
      return false;
    }
  }
}
