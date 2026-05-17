import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/pathfinder_service.dart';
import '../../auth/providers/auth_controller.dart';

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

// 🚀 FIX: Upgraded to AsyncNotifier for true SWR support
class HomeStatsNotifier extends AsyncNotifier<HomeStats> {
  
  @override
  FutureOr<HomeStats> build() async {
    // Watches auth state so the cache resets if they log out
    ref.watch(authStateProvider);
    return _fetchData();
  }

  // 🚀 THE MAGIC METHOD: Fetches data and updates state WITHOUT triggering 'isLoading'
  Future<void> refreshSilently() async {
    try {
      final newData = await _fetchData();
      // Instantly injects the new data into the UI without triggering a loading rebuild flicker!
      state = AsyncData(newData);
    } catch (e) {
      debugPrint("Silent refresh failed (User might be offline): $e");
      // We do NOT change the state to Error here, so the user keeps seeing their cached data safely.
    }
  }

  Future<HomeStats> _fetchData() async {
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

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

    final profileFuture = client
        .from('profiles')
        .select('current_streak, total_xp, full_name, profile_picture_url') 
        .eq('id', user.id)
        .maybeSingle()
        .catchError((_) => null);

    final scansFuture = client
        .from('scans')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay)
        .catchError((_) => []);

    final rankStatsFuture = client
        .rpc('get_user_rank_stats', params: {'user_id_param': user.id})
        .catchError((_) => {'rank': null, 'total_users': 0});
    
    final recentScansFuture = client
        .from('scans')
        .select('id, object_name, chosen_lens, created_at, image_url')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(3)
        .catchError((_) => []);

    final skillWebFuture = PathfinderService.getSkillWeb()
        .catchError((_) => null);

    final results = await Future.wait<dynamic>([
      profileFuture,
      scansFuture,
      rankStatsFuture, 
      recentScansFuture,
      skillWebFuture,
    ]);

    final profileData = results[0] as Map<String, dynamic>?;
    final scansData = results[1] as List<dynamic>? ?? [];
    final rankStats = results[2] as Map<String, dynamic>? ?? {}; 
    final recentScansData = results[3] as List<dynamic>? ?? [];
    final skillData = results[4] as Map<String, dynamic>?;

    final userRank = rankStats['rank'] as int?;
    final totalUsers = rankStats['total_users'] as int? ?? 0;

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
      totalUsers: totalUsers,
      branchXp: branchXp,
      recentScans: List<Map<String, dynamic>>.from(recentScansData), 
    );
  }
}

// Notice it's an AsyncNotifierProvider now, permanently cached in memory
final homeStatsProvider = AsyncNotifierProvider<HomeStatsNotifier, HomeStats>(() {
  return HomeStatsNotifier();
});