import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeStats {
  final int dailyStreak;
  final int totalPoints;
  final int todayScansCount;
  final String userName;
  final String heroTitle;
  final String? avatarUrl;

  HomeStats({
    required this.dailyStreak,
    required this.totalPoints,
    required this.todayScansCount,
    required this.userName,
    required this.heroTitle,
    this.avatarUrl,
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) {
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer', heroTitle: 'Novice Discoverer', avatarUrl: null,
    );
  }

  try {
    // 1. Fetch exactly what is in your Supabase table
    final profileData = await client
        .from('profiles')
        .select('current_streak, total_xp, full_name, profile_picture_url') // Exact match!
        .eq('id', user.id)
        .maybeSingle();

    // 2. Fetch Today's Scans Count for the daily quest
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

    final scansData = await client
        .from('scans')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay);

    // 3. Map everything directly to the UI
    return HomeStats(
      dailyStreak: profileData?['current_streak'] ?? 0,
      totalPoints: profileData?['total_xp'] ?? 0,
      todayScansCount: (scansData as List).length,
      userName: profileData?['full_name'] ?? 'Explorer',
      heroTitle: 'Curious Scientist', 
      avatarUrl: profileData?['profile_picture_url'], // Pulls your exact column
    );
  } catch (e) {
    // If anything fails, return safe fallback data so the UI doesn't crash
    return HomeStats(
      dailyStreak: 0, totalPoints: 0, todayScansCount: 0,
      userName: 'Explorer', heroTitle: 'Curious Scientist',
    );
  }
});