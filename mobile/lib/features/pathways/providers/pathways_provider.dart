// mobile/lib/features/pathways/providers/pathways_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/pathways_service.dart';
import '../models/pathway_models.dart';
import '../utils/pathway_utils.dart';

const _legacyClaimedPathwayIdsKey = 'pathway_badge_claimed_ids';

final pathwaysServiceProvider = Provider<PathwaysService>((ref) {
  return PathwaysService();
});

class PathwaysCatalogNotifier extends AsyncNotifier<PathwayCatalogResponse> {
  @override
  Future<PathwayCatalogResponse> build() async {
    final catalog = await ref.read(pathwaysServiceProvider).getCatalog();
    final refreshed = await _migrateLegacyLocalClaims(catalog);
    return refreshed ?? catalog;
  }

  /// One-time upload of device-only claims from before server sync existed.
  Future<PathwayCatalogResponse?> _migrateLegacyLocalClaims(
    PathwayCatalogResponse catalog,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final localIds = prefs.getStringList(_legacyClaimedPathwayIdsKey);
    if (localIds == null || localIds.isEmpty) return null;

    final localSet = localIds.toSet();
    final serverClaimed = catalog.pathways
        .where((p) => p.badgeClaimed)
        .map((p) => p.id)
        .toSet();
    final pending = localSet.difference(serverClaimed);
    if (pending.isEmpty) {
      await prefs.remove(_legacyClaimedPathwayIdsKey);
      return null;
    }

    final service = ref.read(pathwaysServiceProvider);
    var didSync = false;

    for (final pathwayId in pending) {
      final matches =
          catalog.pathways.where((p) => p.id == pathwayId).toList();
      if (matches.isEmpty) continue;
      final pathway = matches.first;
      if (!isPathwayQuestFinished(pathway)) continue;

      try {
        await service.claimPathwayBadge(pathwayId);
        didSync = true;
      } catch (_) {
        // Keep legacy ids for a later attempt if the server is unavailable.
      }
    }

    if (!didSync) return null;

    await prefs.remove(_legacyClaimedPathwayIdsKey);
    return ref.read(pathwaysServiceProvider).getCatalog();
  }

  Future<void> enroll(String pathwayId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(pathwaysServiceProvider).enrollInPathway(pathwayId);
      state = AsyncValue.data(
        await ref.read(pathwaysServiceProvider).getCatalog(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> claimBadge(String pathwayId) async {
    await ref.read(pathwaysServiceProvider).claimPathwayBadge(pathwayId);
    state = AsyncValue.data(
      await ref.read(pathwaysServiceProvider).getCatalog(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(pathwaysServiceProvider).getCatalog(),
    );
  }
}

final pathwaysCatalogProvider =
    AsyncNotifierProvider<PathwaysCatalogNotifier, PathwayCatalogResponse>(() {
      return PathwaysCatalogNotifier();
    });
