// mobile/lib/features/pathways/services/compass_recommendation_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/pathway_models.dart';

class CompassAffinityScores {
  final int stemAffinity;
  final int abmAffinity;
  final int humssAffinity;
  final int tvlAffinity;

  const CompassAffinityScores({
    required this.stemAffinity,
    required this.abmAffinity,
    required this.humssAffinity,
    required this.tvlAffinity,
  });

  /// Returns the dominant strand label (matches Pathway.targetStrand values)
  String get dominantStrand {
    final scores = {
      'STEM': stemAffinity,
      'ABM': abmAffinity,
      'HUMSS': humssAffinity,
      'TVL': tvlAffinity,
    };
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Returns all strands sorted by affinity descending
  List<MapEntry<String, int>> get rankedStrands {
    final scores = {
      'STEM': stemAffinity,
      'ABM': abmAffinity,
      'HUMSS': humssAffinity,
      'TVL': tvlAffinity,
    };
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  /// Score 0–100 for how well a pathway's target strand matches this profile
  int matchScore(String targetStrand) {
    final upper = targetStrand.toUpperCase();
    switch (upper) {
      case 'STEM':
        return stemAffinity;
      case 'ABM':
        return abmAffinity;
      case 'HUMSS':
        return humssAffinity;
      case 'TVL':
        return tvlAffinity;
      case 'GENERAL':
        // General pathways are a moderate fit for everyone
        final avg = (stemAffinity + abmAffinity + humssAffinity + tvlAffinity) ~/ 4;
        return avg;
      default:
        return 0;
    }
  }

  bool get hasData =>
      stemAffinity > 0 || abmAffinity > 0 || humssAffinity > 0 || tvlAffinity > 0;
}

class RecommendedPathway {
  final Pathway pathway;
  final int matchScore; // 0–100
  final bool isPerfectMatch; // top strand match

  const RecommendedPathway({
    required this.pathway,
    required this.matchScore,
    required this.isPerfectMatch,
  });
}

class CompassRecommendationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<CompassAffinityScores?> fetchCompassScores() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('compass_results')
          .select('stem_affinity, abm_affinity, humss_affinity, tvl_affinity')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return CompassAffinityScores(
        stemAffinity: (response['stem_affinity'] as int?) ?? 0,
        abmAffinity: (response['abm_affinity'] as int?) ?? 0,
        humssAffinity: (response['humss_affinity'] as int?) ?? 0,
        tvlAffinity: (response['tvl_affinity'] as int?) ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error fetching compass scores: $e');
      return null;
    }
  }

  /// Sorts and scores pathways against the user's compass results.
  /// Returns recommended pathways ranked by match score descending.
  List<RecommendedPathway> rankPathways(
    List<Pathway> pathways,
    CompassAffinityScores scores,
  ) {
    final dominantStrand = scores.dominantStrand;

    final ranked = pathways.map((p) {
      final match = scores.matchScore(p.targetStrand);
      final isPerfect = p.targetStrand.toUpperCase() == dominantStrand;
      return RecommendedPathway(
        pathway: p,
        matchScore: match,
        isPerfectMatch: isPerfect,
      );
    }).toList()
      ..sort((a, b) {
        // Perfect matches first, then by score descending, then by progress
        if (a.isPerfectMatch != b.isPerfectMatch) {
          return a.isPerfectMatch ? -1 : 1;
        }
        if (b.matchScore != a.matchScore) {
          return b.matchScore.compareTo(a.matchScore);
        }
        // Prefer in-progress pathways over available ones
        final aActive = a.pathway.status == PathwayStatus.active ? 1 : 0;
        final bActive = b.pathway.status == PathwayStatus.active ? 1 : 0;
        return bActive.compareTo(aActive);
      });

    return ranked;
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────────────────

final compassRecommendationServiceProvider =
    Provider<CompassRecommendationService>((_) => CompassRecommendationService());

final compassAffinityProvider =
    FutureProvider.autoDispose<CompassAffinityScores?>((ref) async {
  final service = ref.watch(compassRecommendationServiceProvider);
  return service.fetchCompassScores();
});