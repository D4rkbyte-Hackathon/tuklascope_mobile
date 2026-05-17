import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? educationLevel;
  final String? city;
  final String? country;
  final int totalXp;
  final int currentLevel;
  final int currentStreak;
  final DateTime? lastActionDate;
  final String? bio;
  final String? profilePictureUrl;
  final String? displayBadge1;
  final String? displayBadge2;
  final String? displayBadge3;

  List<String?> get displayBadges => [displayBadge1, displayBadge2, displayBadge3];

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.educationLevel,
    this.city,
    this.country,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    this.lastActionDate,
    this.bio,
    this.profilePictureUrl,
    this.displayBadge1,
    this.displayBadge2,
    this.displayBadge3,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      educationLevel: json['education_level'],
      city: json['city'],
      country: json['country'],
      totalXp: json['total_xp'] ?? 0,
      currentLevel: json['current_level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      lastActionDate: json['last_action_date'] != null
          ? DateTime.parse(json['last_action_date'])
          : null,
      bio: json['bio'],
      profilePictureUrl: json['profile_picture_url'],
      displayBadge1: _nullableProfileString(json['display_badge_1']),
      displayBadge2: _nullableProfileString(json['display_badge_2']),
      displayBadge3: _nullableProfileString(json['display_badge_3']),
    );
  }
}

String? _nullableProfileString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

class SkillTree {
  final String userId;
  final int aghamMathXp;
  final int siningWikaXp;
  final int negosyoPamamahalaXp;
  final int buhayKasanayanXp;

  SkillTree({
    required this.userId,
    required this.aghamMathXp,
    required this.siningWikaXp,
    required this.negosyoPamamahalaXp,
    required this.buhayKasanayanXp,
  });

  factory SkillTree.fromJson(Map<String, dynamic> json) {
    return SkillTree(
      userId: json['user_id'],
      aghamMathXp: json['agham_math_xp'] ?? 0,
      siningWikaXp: json['sining_wika_xp'] ?? 0,
      negosyoPamamahalaXp: json['negosyo_pamamahala_xp'] ?? 0,
      buhayKasanayanXp: json['buhay_kasanayan_xp'] ?? 0,
    );
  }
}

// This is our Master State object
class AppUser {
  final User auth;
  final UserProfile profile;
  final SkillTree skillTree;

  AppUser({required this.auth, required this.profile, required this.skillTree});
}
