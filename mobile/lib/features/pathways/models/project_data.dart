class ProjectData {
  final String title;
  final String description;
  final String image;
  final String difficulty;
  final int points;
  final int progress;
  final List<String> tasks;

  ProjectData({
    required this.title,
    required this.description,
    required this.image,
    required this.difficulty,
    required this.points,
    required this.progress,
    required this.tasks,
  });
}