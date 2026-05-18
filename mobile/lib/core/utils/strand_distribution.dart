import '../../features/onboarding/models/compass_data.dart';
import '../../features/pathways/services/compass_recommendation_service.dart';

/// Blends Neo4j skill-tree XP with onboarding Compass affinity into a single
/// 0–1 distribution for radar charts (Pathfinder, etc.).
Map<Affinity, double> blendStrandAffinityScores({
  int stemXp = 0,
  int humssXp = 0,
  int abmXp = 0,
  int tvlXp = 0,
  CompassAffinityScores? compass,
}) {
  Map<Affinity, double>? skillTreeScores;
  final skillTotal = stemXp + humssXp + abmXp + tvlXp;
  if (skillTotal > 0) {
    skillTreeScores = {
      Affinity.stem: stemXp / skillTotal,
      Affinity.humss: humssXp / skillTotal,
      Affinity.abm: abmXp / skillTotal,
      Affinity.tvl: tvlXp / skillTotal,
    };
  }

  Map<Affinity, double>? compassScores;
  if (compass != null && compass.hasData) {
    final compassTotal = compass.stemAffinity +
        compass.abmAffinity +
        compass.humssAffinity +
        compass.tvlAffinity;
    if (compassTotal > 0) {
      compassScores = {
        Affinity.stem: compass.stemAffinity / compassTotal,
        Affinity.humss: compass.humssAffinity / compassTotal,
        Affinity.abm: compass.abmAffinity / compassTotal,
        Affinity.tvl: compass.tvlAffinity / compassTotal,
      };
    }
  }

  if (skillTreeScores != null && compassScores != null) {
    return {
      for (final affinity in Affinity.values)
        affinity:
            (skillTreeScores[affinity]! + compassScores[affinity]!) / 2,
    };
  }

  return skillTreeScores ??
      compassScores ??
      const {
        Affinity.stem: 0.0,
        Affinity.humss: 0.0,
        Affinity.abm: 0.0,
        Affinity.tvl: 0.0,
      };
}
