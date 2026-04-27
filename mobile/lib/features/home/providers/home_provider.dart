import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeStats {
  final int dailyStreak;
  final int totalPoints;
  final int todayScansCount;
  final String userName;
  final String heroTitle;

  HomeStats({
    required this.dailyStreak,
    required this.totalPoints,
    required this.todayScansCount,
    required this.userName,
    required this.heroTitle,
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null) {
    return HomeStats(
      dailyStreak: 0, 
      totalPoints: 0, 
      todayScansCount: 0,
      userName: 'Explorer',
      heroTitle: 'Novice Discoverer',
    );
  }

  final profileData = await client
      .from('profiles')
      .select('current_streak, total_xp') // Add 'name' to your DB query later
      .eq('id', userId)
      .maybeSingle();

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

  final scansData = await client
      .from('scans')
      .select('id')
      .eq('user_id', userId)
      .gte('created_at', startOfDay);

  return HomeStats(
    dailyStreak: profileData?['current_streak'] ?? 0,
    totalPoints: profileData?['total_xp'] ?? 0,
    todayScansCount: (scansData as List).length,
    userName: profileData?['name'] ?? 'Explorer',
    heroTitle: 'Curious Scientist', 
  );
});