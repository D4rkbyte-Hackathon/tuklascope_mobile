import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream that listens to whether the user is logged in or out
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Get the currently logged-in user
  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      if (webClientId == null || webClientId.isEmpty) {
        throw Exception('GOOGLE_WEB_CLIENT_ID is missing from the .env file');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(serverClientId: webClientId);

      // Trigger the native popup
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Extract the authentication data
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 🚀 V7 FIX: We ONLY grab the idToken.
      // accessToken was removed in v7, but Supabase doesn't need it anyway!
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Failed to retrieve Google Auth ID Token.';
      }

      // Hand the token over to Supabase
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // 🚀 V7 FIX: We completely removed the accessToken parameter here.
      );
    } catch (e) {
      // ignore: avoid_print
      print('Google Sign-In Exception: $e');
      rethrow;
    }
  }

  Future<AuthResponse?> signInWithFacebook() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        // Add this line exactly as you typed it in Supabase
        redirectTo: 'io.supabase.tuklascope://login-callback', 
      );
      return null; 
    } catch (e) {
      rethrow;
    }
  }
  // Check if the current user is a Google sign-in user
  bool isGoogleUser() {
    final user = currentUser;
    if (user == null) return false;
    
    // Check if 'google' is in the list of providers for this user
    final providers = user.appMetadata['providers'] as List?;
    return providers?.contains('google') ?? false;
  }

  /// Check if user is email/password based (not OAuth)
  bool isEmailPasswordUser() {
    final user = currentUser;
    if (user == null) return false;
    
    final providers = user.appMetadata['providers'] as List?;
    // If ONLY 'email' is in providers (no google/facebook), it's email user
    return (providers != null && 
            providers.contains('email') && 
            !providers.contains('google') && 
            !providers.contains('facebook'));
  }

  /// Check if user is OAuth user (Google or Facebook)
  bool isOAuthUser() {
    final user = currentUser;
    if (user == null) return false;
    
    final providers = user.appMetadata['providers'] as List?;
    return (providers != null && 
            (providers.contains('google') || providers.contains('facebook')));
  }

  /// Change user password (only for email/password users)
  Future<void> changePassword(String newPassword) async {
    if (!isEmailPasswordUser()) {
      throw Exception(
        'Password change is only available for email/password accounts. '
        'OAuth users (Google/Facebook) cannot change password.',
      );
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('✓ Password changed successfully');
    } catch (e) {
      print('✗ Error changing password: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    await _supabase.auth.signOut();
  }
}
