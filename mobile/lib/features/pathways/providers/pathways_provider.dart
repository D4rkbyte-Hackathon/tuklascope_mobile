// mobile/lib/features/pathways/providers/pathways_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pathways_service.dart';
import '../models/pathway_models.dart';

final pathwaysServiceProvider = Provider<PathwaysService>((ref) {
  return PathwaysService();
});

// AsyncNotifier allows us to mutate the state (e.g., refreshing after enrollment)
class PathwaysCatalogNotifier extends AsyncNotifier<PathwayCatalogResponse> {
  @override
  Future<PathwayCatalogResponse> build() async {
    return await ref.read(pathwaysServiceProvider).getCatalog();
  }

  Future<void> enroll(String pathwayId) async {
    // Keep the previous state but mark it as loading so we can show a spinner
    state = const AsyncValue.loading();
    try {
      await ref.read(pathwaysServiceProvider).enrollInPathway(pathwayId);
      // Re-fetch the catalog to get the new 'active' status and tasks
      state = AsyncValue.data(
        await ref.read(pathwaysServiceProvider).getCatalog(),
      );
    } catch (e, stack) {
      // If it fails, restore the previous state and set the error
      state = AsyncValue.error(e, stack);
    }
  }

  // Method to force a soft refresh
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
