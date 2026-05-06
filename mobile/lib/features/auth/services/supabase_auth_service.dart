import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

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
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return null; // User canceled the sign-in

      // Extract the authentication data
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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

  // ===========================================================================
  // 🚀 ADDED: EMAIL EXISTENCE CHECK
  // ===========================================================================
  /// Checks the database to see if an email is already registered.
  /// Ensure your RLS policies on the 'profiles' table allow unauthenticated SELECTs on the email column.
  Future<bool> checkIfEmailExists(String email) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      // If we got a response back, the email already exists in the database
      return response != null;
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      // If it fails (e.g. due to RLS), we return false so we don't completely lock out signups,
      // but ideally, your RLS allows this read, or you use a secure RPC function instead.
      return false;
    }
  }

  // ===========================================================================
  // OTP METHODS
  // ===========================================================================

  /// Sends a verification OTP to the user's email during signup
  /// Sends a verification OTP to the user's email during signup
  Future<bool> sendSignupVerificationOtp({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 🚀 THE FIX: Supabase Email Enumeration Protection Check
      // If the user object is returned but 'identities' is empty, 
      // it means the email is already registered in the system.
      if (response.user != null && response.user!.identities != null && response.user!.identities!.isEmpty) {
        debugPrint('❌ Email already exists (Caught by Enumeration Protection)');
        return false; 
      }

      debugPrint('✅ OTP sent successfully to $email');
      return true; 
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error sending OTP: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error sending OTP: $e');
      return false;
    }
  }

  /// Verifies the 6-digit code sent to the user's inbox
  Future<bool> verifyEmailWithOtp({
    required String email, 
    required String otpCode,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otpCode,
        type: OtpType.signup, 
      );
      if (response.session != null) {
        debugPrint('✅ Email verified successfully for $email');
        return true;
      }
      debugPrint('❌ OTP verification failed: No session returned');
      return false;
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error verifying OTP: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error verifying OTP: $e');
      return false;
    }
  }
}