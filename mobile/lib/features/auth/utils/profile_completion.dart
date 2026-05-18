/// Whether the user finished the same onboarding fields as email signup
/// (name, education, avatar — not email/password).
bool isProfileOnboardingComplete(Map<String, dynamic>? profile) {
  if (profile == null) return false;

  final name = profile['full_name']?.toString().trim() ?? '';
  final education = profile['education_level']?.toString().trim() ?? '';
  final avatar = profile['profile_picture_url']?.toString().trim() ?? '';

  return name.isNotEmpty && education.isNotEmpty && avatar.isNotEmpty;
}
