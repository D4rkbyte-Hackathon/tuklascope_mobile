import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import '../models/profile_models.dart';
import '../../../core/services/pathfinder_service.dart';

final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return ProfileStats(
      totalXp: 0, currentLevel: 1, conceptsMastered: 0,
      stemXp: 0, humssXp: 0, abmXp: 0, tvlXp: 0, topSkills: [],
    );
  }

  final profileRes = await client.from('profiles').select('total_xp, current_level').eq('id', userId).maybeSingle();
  final treeRes = await client.from('kaalaman_skill_tree').select().eq('user_id', userId).maybeSingle();
  final scansRes = await client.from('scans').select('id').eq('user_id', userId);
  final neo4jData = await PathfinderService.getSkillWeb();

  List<String> parsedTopSkills = [];
  if (neo4jData != null && neo4jData['top_skills'] != null) {
    parsedTopSkills = List<String>.from(neo4jData['top_skills']);
  }

  return ProfileStats(
    totalXp: profileRes?['total_xp'] ?? 0,
    currentLevel: profileRes?['current_level'] ?? 1,
    conceptsMastered: (scansRes as List).length,
    stemXp: treeRes?['agham_math_xp'] ?? 0,
    humssXp: treeRes?['sining_wika_xp'] ?? 0,
    abmXp: treeRes?['negosyo_pamamahala_xp'] ?? 0,
    tvlXp: treeRes?['buhay_kasanayan_xp'] ?? 0,
    topSkills: parsedTopSkills,
  );
});

List<SkillNode> generateSkillNodes(ProfileStats stats, String userName, ThemeData theme) {
  final nodes = <SkillNode>[];

  nodes.add(SkillNode(
    id: 'root', title: userName.toUpperCase(), description: 'Your central learning core.',
    strand: 'root', xp: stats.totalXp, level: stats.currentLevel,
    color: theme.colorScheme.primary, angle: 0, radialDistance: 0, radius: 50.0,
  ));

  final strandData = {
    'stem': {'xp': stats.stemXp, 'angle': -math.pi * 0.75, 'color': Colors.green[600]!},
    'abm': {'xp': stats.abmXp, 'angle': -math.pi * 0.25, 'color': Colors.blue[600]!},
    'tvl': {'xp': stats.tvlXp, 'angle': math.pi * 0.25, 'color': Colors.red[500]!},
    'humss': {'xp': stats.humssXp, 'angle': math.pi * 0.75, 'color': Colors.orange[600]!},
  };

  strandData.forEach((id, data) {
    final strandXp = data['xp'] as int;
    nodes.add(SkillNode(
      id: id, title: id.toUpperCase(), description: 'Core SHS Pathway', strand: 'root',
      xp: strandXp, level: (strandXp ~/ 500) + 1,
      color: data['color'] as Color, angle: data['angle'] as double, radialDistance: 130.0, radius: 38.0,
    ));
  });

  final topicColors = [Colors.cyan.shade400, Colors.pink.shade400, Colors.amber.shade400, Colors.deepPurple.shade300];
  final strandSkillCounts = <String, int>{};

  for (int i = 0; i < stats.topSkills.length; i++) {
    final skillString = stats.topSkills[i];
    final regex = RegExp(r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$');
    final match = regex.firstMatch(skillString);

    String skillName = skillString;
    String domainName = 'Discipline';
    String strandName = 'stem';
    int parsedLevel = 1;

    if (match != null) {
      skillName = match.group(1)?.trim() ?? skillName;
      domainName = match.group(2)?.trim() ?? domainName;
      strandName = match.group(3)?.trim().toLowerCase() ?? 'stem';
      parsedLevel = int.tryParse(match.group(4) ?? '1') ?? 1;
    }

    if (!strandData.containsKey(strandName)) strandName = 'stem';

    final parentData = strandData[strandName]!;
    final baseAngle = parentData['angle'] as double;
    final parentColor = parentData['color'] as Color;

    final count = strandSkillCounts[strandName] ?? 0;
    strandSkillCounts[strandName] = count + 1;

    final offset = (count == 0) ? 0.0 : (count % 2 == 0 ? 1 : -1) * ((count + 1) ~/ 2) * 0.35;
    final finalAngle = baseAngle + offset;

    nodes.add(SkillNode(
      id: 'skill_$i', title: skillName, description: domainName, strand: strandName,
      xp: parsedLevel * 50, level: parsedLevel,
      color: count == 0 ? parentColor : topicColors[i % topicColors.length],
      angle: finalAngle, radialDistance: 270.0 + (count > 2 ? 40 : 0),
      radius: (30.0 + (parsedLevel * 2.0)).clamp(30.0, 45.0),
    ));
  }
  return nodes;
}