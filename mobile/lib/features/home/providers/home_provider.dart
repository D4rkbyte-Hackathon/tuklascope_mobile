import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/pathfinder_service.dart';

class HomeStats {
  final String? userId;
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
    required this.userId,
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

  static HomeStats empty({String? userId}) => HomeStats(
        userId: userId,
        dailyStreak: 0,
        totalPoints: 0,
        todayScansCount: 0,
        userName: 'Explorer',
        avatarUrl: null,
        userRank: null,
        totalUsers: 0,
        branchXp: const {'STEM': 0, 'HUMSS': 0, 'ABM': 0, 'TVL': 0},
        recentScans: const [],
      );
}

class HomeStatsNotifier extends AsyncNotifier<HomeStats> {
  HomeStatsNotifier(this.userId);

  final String? userId;
  int _fetchGeneration = 0;

  @override
  FutureOr<HomeStats> build() async {
    if (userId == null) {
      return HomeStats.empty();
    }

    final generation = ++_fetchGeneration;
    final data = await _fetchData(userId!, generation: generation);

    if (generation != _fetchGeneration ||
        Supabase.instance.client.auth.currentUser?.id != userId) {
      throw StateError('Stale home stats fetch');
    }

    return data;
  }

  Future<void> refreshSilently() async {
    if (userId == null) return;

    final generation = ++_fetchGeneration;
    try {
      final newData = await _fetchData(userId!, generation: generation);
      if (generation != _fetchGeneration) return;
      state = AsyncData(newData);
    } catch (e) {
      debugPrint('Silent refresh failed (User might be offline): $e');
    }
  }

  Future<HomeStats> _fetchData(String userId, {required int generation}) async {
    final client = Supabase.instance.client;

    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

    final profileFuture = client
        .from('profiles')
        .select('current_streak, total_xp, full_name, profile_picture_url')
        .eq('id', userId)
        .maybeSingle()
        .catchError((_) => null);

    final scansFuture = client
        .from('scans')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfDay)
        .catchError((_) => []);

    final rankStatsFuture = client
        .rpc('get_user_rank_stats', params: {'user_id_param': userId})
        .catchError((_) => {'rank': null, 'total_users': 0});

    final recentScansFuture = client
        .from('scans')
        .select('id, object_name, chosen_lens, created_at, image_url')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(30)
        .catchError((_) => []);

    final skillWebFuture =
        PathfinderService.getSkillWeb().catchError((_) => null);

    final results = await Future.wait<dynamic>([
      profileFuture,
      scansFuture,
      rankStatsFuture,
      recentScansFuture,
      skillWebFuture,
    ]);

    if (generation != _fetchGeneration ||
        client.auth.currentUser?.id != userId) {
      return HomeStats.empty(userId: userId);
    }

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
      // Neo4j returns lowercase keys (stem, humss, …); keep uppercase for UI maps.
      int xpFor(String lower, String upper) =>
          int.tryParse(
                (dist[lower] ?? dist[upper])?.toString() ?? '0',
              ) ??
          0;
      branchXp = {
        'STEM': xpFor('stem', 'STEM'),
        'HUMSS': xpFor('humss', 'HUMSS'),
        'ABM': xpFor('abm', 'ABM'),
        'TVL': xpFor('tvl', 'TVL'),
      };
    }

    return HomeStats(
      userId: userId,
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

final homeStatsProvider =
    AsyncNotifierProvider.family<HomeStatsNotifier, HomeStats, String?>(
  HomeStatsNotifier.new,
);
