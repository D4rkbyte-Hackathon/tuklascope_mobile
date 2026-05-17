import 'package:shared_preferences/shared_preferences.dart';

/// Device-local persistence for starred scans (per user).
class ScanFavoritesStore {
  static String _key(String userId) => 'favorite_scan_ids_$userId';

  static Future<Set<String>> getFavoriteIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key(userId))?.toSet() ?? {};
  }

  static Future<void> setFavorite({
    required String userId,
    required String scanId,
    required bool isFavorite,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key(userId))?.toSet() ?? {};

    if (isFavorite) {
      favorites.add(scanId);
    } else {
      favorites.remove(scanId);
    }

    await prefs.setStringList(_key(userId), favorites.toList());
  }
}
