import 'dart:async'; // Fixes FutureOr error
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../models/app_user.dart';
import '../services/supabase_auth_service.dart';

// ==========================================
// 1. SERVICES & BASIC STATE
// ==========================================

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

// ==========================================
// 2. ACTION CONTROLLER (For Login/Signup UI)
// ==========================================

class AuthController extends AsyncNotifier<void> {
  late SupabaseAuthService _authService;

  @override
  FutureOr<void> build() {
    _authService = ref.watch(authServiceProvider);
  }

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();
    try {
      final response = await _authService.signInWithEmailPassword(
        email,
        password,
      );
      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow; // Passes error to UI for snackbars
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();
    try {
      final response = await _authService.signUpWithEmailPassword(
        email,
        password,
      );
      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<AuthResponse?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final response = await _authService.signInWithGoogle();
      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

// ==========================================
// 3. MASTER APP STATE (Realtime Database Sync)
// ==========================================

final appUserProvider = StreamProvider<AppUser?>((ref) async* {
  final user = await ref.watch(authStateProvider.future);
  final supabase = ref.watch(supabaseClientProvider);

  if (user == null) {
    yield null; // User is definitively logged out
    return;
  }

  // Define streams for the current user's profile and skill tree
  final profileStream = supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map(
        (event) => event.isNotEmpty ? UserProfile.fromJson(event.first) : null,
      );

  final skillTreeStream = supabase
      .from('kaalaman_skill_tree')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', user.id)
      .map(
        (event) => event.isNotEmpty ? SkillTree.fromJson(event.first) : null,
      );

  // Combine them into our AppUser master object
  yield* Rx.combineLatest2<UserProfile?, SkillTree?, AppUser?>(
    profileStream,
    skillTreeStream,
    (profile, skillTree) {
      // Guard against race conditions where the DB trigger hasn't fired yet.
      // We return null here, which is filtered out below.
      if (profile == null || skillTree == null) return null;

      return AppUser(auth: user, profile: profile, skillTree: skillTree);
    },
  ).where((user) => user != null); // Prevents emitting until triggers complete
});
