import 'package:flutter/material.dart';

import '../models/pathway_models.dart';

bool isPathwayQuestFinished(Pathway pathway) {
  if (pathway.status == PathwayStatus.completed) return true;
  if (pathway.tasks.isEmpty) return false;
  return pathway.tasks.every((task) => task.isCompleted);
}

bool isPathwayBadgeUnlocked(Pathway pathway) => pathway.badgeClaimed;

bool canClaimPathwayBadge(Pathway pathway) {
  return isPathwayQuestFinished(pathway) && !pathway.badgeClaimed;
}

// Removed the '_' so this can be imported and used anywhere
Color getProgressColor(int progress) {
  if (progress <= 40) return Colors.orangeAccent;
  if (progress <= 60) return Colors.yellow[700]!;
  if (progress <= 80) return Colors.lime;
  return Colors.green;
}