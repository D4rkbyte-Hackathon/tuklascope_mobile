import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/pathfinder_service.dart';

class HomeStats {
  final int dailyStreak;
  final int totalPoints;
  final int todayScansCount;
  final String userName;
  final String? avatarUrl;
  final int? userRank;          
  final int totalUsers;         
  final Map<String, int> branchXp; 
  final List<Map<String, dynamic>> recentScans; 

  HomeStats({
    required this.dailyStreak,
    required this.totalPoints,
    required this.todayScansCount,
    required this.userName,
    this.avatarUrl,
    this.userRank,
    required this.totalUsers,
    required this.branchXp,
    required this.recentScans, 
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  
  // 🚀 Keeps the data alive so switching tabs doesn't trigger a reload
  ref.keepAlive();

  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) {
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer', avatarUrl: null,
      userRank: null, totalUsers: 0, branchXp: {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0},
      recentScans: [],
    );
  }

  try {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

    // 🚀 1. FIRE ALL REQUESTS CONCURRENTLY WITH FAIL-SAFES
    
    // Fetch Profile
    final profileFuture = client
        .from('profiles')
        .select('current_streak, total_xp, full_name, profile_picture_url') 
        .eq('id', user.id)
        .maybeSingle()
        .catchError((_) => null);

    // Fetch Today's Scans Count
    final scansFuture = client
        .from('scans')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay)
        .catchError((_) => []);

    // Fetch Leaderboard Data
    final leaderboardFuture = client
        .from('profiles')
        .select('id, total_xp')
        .order('total_xp', ascending: false)
        .catchError((_) => []);
    
    // Fetch 3 Most Recent Discoveries
    final recentScansFuture = client
        .from('scans')
        .select('id, object_name, chosen_lens, created_at, image_url')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(3)
        .catchError((_) => []);

    // Fetch Real Skill Tree Branch XP from Neo4j
    final skillWebFuture = PathfinderService.getSkillWeb()
        .catchError((_) => null);

    // 🚀 2. AWAIT THEM ALL SIMULTANEOUSLY (Drops load time to ~300ms)
    final results = await Future.wait<dynamic>([
      profileFuture,
      scansFuture,
      leaderboardFuture,
      recentScansFuture,
      skillWebFuture,
    ]);

    // 🚀 3. SAFELY EXTRACT AND CAST DATA
    final profileData = results[0] as Map<String, dynamic>?;
    final scansData = results[1] as List<dynamic>? ?? [];
    final allProfiles = results[2] as List<dynamic>? ?? [];
    final recentScansData = results[3] as List<dynamic>? ?? [];
    final skillData = results[4] as Map<String, dynamic>?;

    // Leaderboard Calculation
    final rankIndex = allProfiles.indexWhere((p) => p['id'] == user.id);
    final userRank = rankIndex != -1 ? rankIndex + 1 : null;

    // Skill Tree Calculation
    Map<String, int> branchXp = {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0};
    if (skillData != null && skillData['xp_distribution'] != null) {
      final dist = skillData['xp_distribution'] as Map<String, dynamic>;
      branchXp = {
        'STEM': (dist['STEM'] ?? 0) as int,
        'HUMSS': (dist['HUMSS'] ?? 0) as int,
        'ABM': (dist['ABM'] ?? 0) as int,
        'TVL': (dist['TVL'] ?? 0) as int,
      };
    }

    return HomeStats(
      dailyStreak: profileData?['current_streak'] as int? ?? 0,
      totalPoints: profileData?['total_xp'] as int? ?? 0,
      todayScansCount: scansData.length,
      userName: profileData?['full_name'] as String? ?? 'Explorer',
      avatarUrl: profileData?['profile_picture_url'] as String?, 
      userRank: userRank,
      totalUsers: allProfiles.length,
      branchXp: branchXp,
      recentScans: List<Map<String, dynamic>>.from(recentScansData), 
    );
    
  } catch (e) {
    debugPrint("Home Provider Overall Error: $e");
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer',
      userRank: null, totalUsers: 0, branchXp: {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0},
      recentScans: [],
    );
  }
});