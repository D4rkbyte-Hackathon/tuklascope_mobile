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

      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
      final googleSignIn = GoogleSignIn.instance;
      const scopes = ['email', 'profile'];

      await googleSignIn.initialize(
        serverClientId: webClientId,
        clientId: (iosClientId != null && iosClientId.isNotEmpty)
            ? iosClientId
            : null,
      );

      final GoogleSignInAccount googleUser;
      try {
        googleUser = await googleSignIn.authenticate(scopeHint: scopes);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // On Android, Credential Manager often reports config errors as "canceled".
          throw Exception(
            'Google Sign-In did not complete. If you did not cancel, check Google '
            'Cloud Console: create an Android OAuth client for package '
            'com.example.tuklascope_mobile with your debug SHA-1, and set '
            'GOOGLE_WEB_CLIENT_ID in .env to your Web client ID (not the Android one).',
          );
        }
        rethrow;
      }

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw Exception(
          'No Google ID token returned. GOOGLE_WEB_CLIENT_ID must be the Web '
          'application client ID from Google Cloud Console.',
        );
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
    } catch (e, st) {
      debugPrint('Google Sign-In Exception: $e\n$st');
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
      if (kDebugMode) {
        print('✓ Password changed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Error changing password: $e');
      }
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
  /// Sends a verification OTP to the user's email during signup
  Future<void> sendSignupVerificationOtp({
    required String email, 
    required String password,
  }) async {
    // 🚀 We no longer use try/catch here. We let the error bubble up to the UI.
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Supabase Email Enumeration Protection Check
    if (response.user != null && response.user!.identities != null && response.user!.identities!.isEmpty) {
      // We manually throw an AuthException so the UI catches it properly
      throw const AuthException('Email already exists. Please log in.'); 
    }
  }

  /// Resends the signup verification OTP to the user's email.
  Future<void> resendSignupVerificationOtp({required String email}) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
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