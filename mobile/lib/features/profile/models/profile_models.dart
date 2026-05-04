import 'package:flutter/material.dart';

class SkillNode {
  final String id;
  final String title;
  final String description;
  final String strand;
  final int xp;
  final int level;
  final Color color;
  final double angle;
  final double radialDistance;
  final double radius;
  final IconData? icon;

  SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.strand,
    required this.xp,
    required this.level,
    required this.color,
    required this.angle,
    required this.radialDistance,
    this.radius = 35.0,
    this.icon,
  });
}

class ProfileStats {
  final int totalXp;
  final int currentLevel;
  final int conceptsMastered;
  final int stemXp;
  final int humssXp;
  final int abmXp;
  final int tvlXp;
  final List<String> topSkills;

  ProfileStats({
    required this.totalXp,
    required this.currentLevel,
    required this.conceptsMastered,
    required this.stemXp,
    required this.humssXp,
    required this.abmXp,
    required this.tvlXp,
    required this.topSkills,
  });

  int get progressToNextLevel => ((totalXp % 500) / 500 * 100).toInt();
}