// mobile/lib/features/pathways/models/pathway_models.dart

enum PathwayStatus { available, active, completed, abandoned }

extension PathwayStatusExtension on PathwayStatus {
  static PathwayStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return PathwayStatus.active;
      case 'completed':
        return PathwayStatus.completed;
      case 'abandoned':
        return PathwayStatus.abandoned;
      default:
        return PathwayStatus.available;
    }
  }
}

class PathwayTask {
  final String id;
  final String description;
  final bool isCompleted;

  PathwayTask({
    required this.id,
    required this.description,
    required this.isCompleted,
  });

  factory PathwayTask.fromJson(Map<String, dynamic> json) {
    return PathwayTask(
      id: json['id'] as String,
      description: json['description'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class Pathway {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String badgeUrl;
  final String difficulty;
  final int totalPoints;
  final String targetStrand;
  final PathwayStatus status;
  final int progressPercentage;
  final bool badgeClaimed;
  final List<PathwayTask> tasks;

  Pathway({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.badgeUrl,
    required this.difficulty,
    required this.totalPoints,
    required this.targetStrand,
    required this.status,
    required this.progressPercentage,
    this.badgeClaimed = false,
    required this.tasks,
  });

  factory Pathway.fromJson(Map<String, dynamic> json) {
    final titleString = json['title'] as String? ?? 'Unknown';
    return Pathway(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      badgeUrl:
          _getBadgePath(titleString, json['badge_url'] as String?),
      difficulty: json['difficulty'] as String,
      totalPoints: json['total_points'] as int? ?? 0,
      targetStrand: json['target_strand'] as String? ?? 'GENERAL',
      status: PathwayStatusExtension.fromString(json['status'] as String),
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      badgeClaimed: json['badge_claimed'] as bool? ?? false,
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => PathwayTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static String _getBadgePath(String title, String? databaseUrl) {
    if (databaseUrl != null && databaseUrl.isNotEmpty) return databaseUrl;

    switch (title) {
      case 'Kitchen Chemist': return 'assets/images/badges/badge_chemist.png';
      case 'Backyard Ecologist': return 'assets/images/badges/badge_ecologist.png';
      case 'Code Creator': return 'assets/images/badges/badge_code.png';
      case 'Math in Nature': return 'assets/images/badges/badge_math.png';
      case 'Physics Explorer': return 'assets/images/badges/badge_physics.png';
      case 'Engineering Innovator': return 'assets/images/badges/badge_engineering.png';
      case 'Market Maestro': return 'assets/images/badges/badge_market.png';
      case 'Community Chronicler': return 'assets/images/badges/badge_chronicler.png';
      case 'Gourmet Artisan': return 'assets/images/badges/badge_gourmet.png';
      case 'Story Architect': return 'assets/images/badges/badge_architect.png';
      default: return 'assets/images/badges/badge_code.png';
    }
  }
}

class PathwayCatalogResponse {
  final int activePathwaysCount;
  final double averageProgress;
  final int totalPointsEarned;
  final List<Pathway> pathways;

  PathwayCatalogResponse({
    required this.activePathwaysCount,
    required this.averageProgress,
    required this.totalPointsEarned,
    required this.pathways,
  });

  factory PathwayCatalogResponse.fromJson(Map<String, dynamic> json) {
    return PathwayCatalogResponse(
      activePathwaysCount: json['active_pathways_count'] as int? ?? 0,
      averageProgress: (json['average_progress'] as num?)?.toDouble() ?? 0.0,
      totalPointsEarned: json['total_points_earned'] as int? ?? 0,
      pathways:
          (json['pathways'] as List<dynamic>?)
              ?.map((e) => Pathway.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
