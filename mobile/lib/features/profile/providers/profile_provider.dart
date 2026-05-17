import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import '../models/profile_models.dart';
import '../../../core/services/pathfinder_service.dart';

final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((
  ref,
) async {
  try {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      return ProfileStats(
        totalXp: 0,
        currentLevel: 1,
        conceptsMastered: 0,
        stemXp: 0,
        humssXp: 0,
        abmXp: 0,
        tvlXp: 0,
        topSkills: [],
      );
    }

    // 1. Fetch Global Stats safely
    final profileRes = await client
        .from('profiles')
        .select('total_xp, current_level')
        .eq('id', userId)
        .maybeSingle();
    final scansRes = await client
        .from('scans')
        .select('id')
        .eq('user_id', userId);

    // 2. Fetch SSOT Graph Data from Neo4j
    final neo4jData = await PathfinderService.getSkillWeb();

    List<dynamic> parsedTopSkills = [];
    Map<String, dynamic> xpDistribution = {};

    if (neo4jData != null) {
      if (neo4jData['top_skills'] is List) {
        parsedTopSkills = List.from(neo4jData['top_skills']);
      }
      if (neo4jData['xp_distribution'] is Map) {
        xpDistribution = Map<String, dynamic>.from(
          neo4jData['xp_distribution'],
        );
      }
    }

    return ProfileStats(
      totalXp: int.tryParse(profileRes?['total_xp']?.toString() ?? '0') ?? 0,
      currentLevel:
          int.tryParse(profileRes?['current_level']?.toString() ?? '1') ?? 1,
      conceptsMastered: (scansRes as List?)?.length ?? 0,
      stemXp: int.tryParse(xpDistribution['stem']?.toString() ?? '0') ?? 0,
      humssXp: int.tryParse(xpDistribution['humss']?.toString() ?? '0') ?? 0,
      abmXp: int.tryParse(xpDistribution['abm']?.toString() ?? '0') ?? 0,
      tvlXp: int.tryParse(xpDistribution['tvl']?.toString() ?? '0') ?? 0,
      topSkills: parsedTopSkills,
    );
  } catch (e, stackTrace) {
    debugPrint('🚨 CRITICAL ERROR in profileStatsProvider: $e');
    debugPrint('🚨 StackTrace: $stackTrace');
    return ProfileStats(
      totalXp: 0,
      currentLevel: 1,
      conceptsMastered: 0,
      stemXp: 0,
      humssXp: 0,
      abmXp: 0,
      tvlXp: 0,
      topSkills: [],
    );
  }
});

List<SkillNode> generateSkillNodes(
  ProfileStats stats,
  String userName,
  ThemeData theme,
) {
  final nodes = <SkillNode>[];

  // 🧮 CONSTANT MATH RULE
  int calculateLevel(int xp) => 1 + (xp ~/ 500);

  // 1. THE CORE
  nodes.add(
    SkillNode(
      id: 'root',
      title: userName.toUpperCase(),
      description: 'Core Entity',
      strand: 'root',
      xp: stats.totalXp,
      level: calculateLevel(stats.totalXp),
      color: theme.colorScheme.primary,
      angle: 0,
      radialDistance: 0,
      radius: 55.0,
    ),
  );

  // 2. THE STRANDS (Connect to Root)
  final strandData = {
    'stem': {
      'xp': stats.stemXp,
      'angle': -math.pi * 0.75,
      'color': Colors.greenAccent[400]!,
    },
    'abm': {
      'xp': stats.abmXp,
      'angle': -math.pi * 0.25,
      'color': Colors.blueAccent[400]!,
    },
    'tvl': {
      'xp': stats.tvlXp,
      'angle': math.pi * 0.25,
      'color': Colors.redAccent[400]!,
    },
    'humss': {
      'xp': stats.humssXp,
      'angle': math.pi * 0.75,
      'color': Colors.orangeAccent[400]!,
    },
  };

  strandData.forEach((id, data) {
    int strandXp = data['xp'] as int;
    nodes.add(
      SkillNode(
        id: id,
        title: id.toUpperCase(),
        description: 'Class Branch',
        strand: 'root',
        xp: strandXp,
        level: calculateLevel(strandXp),
        color: data['color'] as Color,
        angle: data['angle'] as double,
        radialDistance: 110.0,
        radius: 40.0,
        connectedNodeIds: ['root'],
      ),
    );
  });

  // --- PASS 1: MAP UNIQUE DOMAINS & AGGREGATE XP ---
  Map<String, int> domainXpTotals = {};
  Map<String, String> domainPrimaryStrand = {};

  for (var s in stats.topSkills) {
    if (s is! Map) continue;
    int xp = int.tryParse(s['xp']?.toString() ?? '0') ?? 0;
    String strandName = (s['strand'] ?? 'stem').toString().toLowerCase();
    List<dynamic> domainsRaw = s['domains'] is List
        ? List.from(s['domains'])
        : ['General Studies'];
    if (domainsRaw.isEmpty) domainsRaw = ['General Studies'];

    for (var d in domainsRaw) {
      String domainId =
          'domain_${d.toString().replaceAll(' ', '_').toLowerCase()}';
      domainXpTotals[domainId] = (domainXpTotals[domainId] ?? 0) + xp;
      domainPrimaryStrand[domainId] = strandName;
    }
  }

  // --- PASS 2: SPAWN UNIQUE DOMAINS (1 Node per Domain) ---
  Map<String, SkillNode> generatedDomains = {};
  Map<String, int> strandDomainCounts = {};

  domainXpTotals.forEach((domainId, xp) {
    String strandName = domainPrimaryStrand[domainId] ?? 'stem';
    if (!strandData.containsKey(strandName)) strandName = 'stem';

    int dCount = strandDomainCounts[strandName] ?? 0;
    strandDomainCounts[strandName] = dCount + 1;

    double baseAngle = strandData[strandName]!['angle'] as double;
    Color strandColor = strandData[strandName]!['color'] as Color;
    double domainOffset = (dCount == 0)
        ? 0.0
        : (dCount % 2 == 0 ? 1 : -1) * ((dCount + 1) ~/ 2) * 0.45;
    int domainLevel = calculateLevel(xp);

    final domainNode = SkillNode(
      id: domainId,
      title: domainId
          .replaceAll('domain_', '')
          .replaceAll('_', ' ')
          .toUpperCase(),
      description: 'Domain Lv.$domainLevel',
      strand: strandName,
      xp: xp,
      level: domainLevel,
      color: strandColor.withOpacity(0.8),
      angle: baseAngle + domainOffset,
      radialDistance: 220.0,
      radius: (25.0 + (domainLevel * 2.0)).clamp(25.0, 38.0),
      connectedNodeIds: [strandName],
    );
    generatedDomains[domainId] = domainNode;
    nodes.add(domainNode);
  });

  // --- PASS 3: SPAWN UNIQUE SKILLS (1 Node per Skill, MANY connections) ---
  Map<String, int> domainSkillCounts = {};
  final topicColors = [
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
  ];

  for (int i = 0; i < stats.topSkills.length; i++) {
    if (stats.topSkills[i] == null || stats.topSkills[i] is! Map) continue;
    final skillData = Map<String, dynamic>.from(stats.topSkills[i]);

    String skillName = skillData['skill_name']?.toString() ?? 'Unknown Skill';
    int parsedXp = int.tryParse(skillData['xp']?.toString() ?? '0') ?? 0;
    int skillLevel = calculateLevel(parsedXp);

    List<dynamic> domainsRaw = skillData['domains'] is List
        ? List.from(skillData['domains'])
        : ['General Studies'];
    if (domainsRaw.isEmpty) domainsRaw = ['General Studies'];

    List<String> allDomainIds = domainsRaw
        .map((d) => 'domain_${d.toString().replaceAll(' ', '_').toLowerCase()}')
        .toList();
    String primaryDomainId = allDomainIds.first;
    final parentDomain = generatedDomains[primaryDomainId];
    double baseAngle = parentDomain?.angle ?? 0.0;

    int sCount = domainSkillCounts[primaryDomainId] ?? 0;
    domainSkillCounts[primaryDomainId] = sCount + 1;
    double skillOffset = (sCount == 0)
        ? 0.0
        : (sCount % 2 == 0 ? 1 : -1) * ((sCount + 1) ~/ 2) * 0.25;

    nodes.add(
      SkillNode(
        id: 'skill_$i',
        title: skillName,
        description: 'Mastery Lv.$skillLevel',
        strand: primaryDomainId,
        xp: parsedXp,
        level: skillLevel,
        color: topicColors[i % topicColors.length],
        angle: baseAngle + skillOffset,
        radialDistance: 330.0 + (sCount > 2 ? 30 : 0),
        radius: (18.0 + (skillLevel * 3.0)).clamp(18.0, 35.0),
        connectedNodeIds: allDomainIds, // Connects to ALL parent domains
      ),
    );
  }

  return nodes;
}
