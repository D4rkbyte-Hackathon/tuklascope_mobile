import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeStats {
  final int dailyStreak;
  final int totalPoints;
  final int todayScansCount;
  final String userName;
  final String heroTitle;
  final String? avatarUrl;
  final int? userRank;          
  final int totalUsers;         
  final Map<String, int> branchXp; 
  final List<Map<String, dynamic>> recentScans; // 🚀 Added Recent Scans

  HomeStats({
    required this.dailyStreak,
    required this.totalPoints,
    required this.todayScansCount,
    required this.userName,
    required this.heroTitle,
    this.avatarUrl,
    this.userRank,
    required this.totalUsers,
    required this.branchXp,
    required this.recentScans, // 🚀
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) {
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer', heroTitle: 'Novice Discoverer', avatarUrl: null,
      userRank: null, totalUsers: 0, branchXp: {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0},
      recentScans: [],
    );
  }

  try {
    // 1. Fetch Profile
    final profileData = await client
        .from('profiles')
        .select('current_streak, total_xp, full_name, profile_picture_url') 
        .eq('id', user.id)
        .maybeSingle();

    // 2. Fetch Today's Scans Count
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();
    final scansData = await client
        .from('scans')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay);

    // 3. Fetch Leaderboard Rank
    final allProfiles = await client
        .from('profiles')
        .select('id, total_xp')
        .order('total_xp', ascending: false);
    
    final profilesList = allProfiles as List;
    final rankIndex = profilesList.indexWhere((p) => p['id'] == user.id);
    final userRank = rankIndex != -1 ? rankIndex + 1 : null;

    // 4. 🚀 Fetch 3 Most Recent Discoveries
    final recentScansData = await client
        .from('scans')
        .select('id, object_name, chosen_lens, created_at, image_url')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(3);

    // 5. Skill Tree Branch XP (Mocked)
    final branchXp = {'STEM': 120, 'HUMSS': 90, 'ABM': 150, 'TVL': 60};

    return HomeStats(
      dailyStreak: profileData?['current_streak'] ?? 0,
      totalPoints: profileData?['total_xp'] ?? 0,
      todayScansCount: (scansData as List).length,
      userName: profileData?['full_name'] ?? 'Explorer',
      heroTitle: 'Curious Scientist', 
      avatarUrl: profileData?['profile_picture_url'], 
      userRank: userRank,
      totalUsers: profilesList.length,
      branchXp: branchXp,
      recentScans: List<Map<String, dynamic>>.from(recentScansData), // 🚀 Mapped
    );
  } catch (e) {
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer', heroTitle: 'Curious Scientist',
      userRank: null, totalUsers: 0, branchXp: {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0},
      recentScans: [],
    );
  }
});