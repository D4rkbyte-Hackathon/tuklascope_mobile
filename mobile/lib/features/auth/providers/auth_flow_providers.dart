import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/profile_completion.dart';

final profileCompletionCheckProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  try {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('full_name, education_level, profile_picture_url')
        .eq('id', userId)
        .maybeSingle();
    return isProfileOnboardingComplete(profile);
  } catch (e) {
    debugPrint('Profile completion check error: $e');
    return false;
  }
});

final compassCheckProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  try {
    final row = await Supabase.instance.client
        .from('compass_results')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  } catch (e) {
    debugPrint('Compass check error: $e');
    // If we cannot read results, avoid trapping the user in a repeat compass loop.
    return true;
  }
});
