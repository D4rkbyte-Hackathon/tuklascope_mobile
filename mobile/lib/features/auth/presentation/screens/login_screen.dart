import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../onboarding/compass_questions_screen.dart';
import 'signup_screen.dart'; 

import '../../providers/auth_provider.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // Added state variable for password toggle

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already signed in.'),
            backgroundColor: Color(0xFF64B5F6),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final authResponse = await ref
          .read(authServiceProvider)
          .signInWithGoogle();

      if (authResponse != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully signed in with Google!'),
              backgroundColor: Color(0xFF64B5F6),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to sign in with Google';
        if (e.toString().contains('MISSING_EMAIL')) {
          errorMessage = 'Google account has no email. Please use another account.';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Google Sign In was cancelled or failed. Please try again.';
        } else if (e.toString().contains('GOOGLE_WEB_CLIENT_ID is missing')) {
          errorMessage = 'Google configuration is missing. Please contact support.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- TITLE ANIMATION ---
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B3C6A), 
                  ),
                )
                .animate()
                .fade(duration: 600.ms, delay: 100.ms)
                .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 100.ms),
                
                const SizedBox(height: 48),

                // --- EMAIL FIELD ANIMATION ---
                _buildCustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                )
                .animate()
                .fade(duration: 600.ms, delay: 200.ms)
                .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 200.ms),
                
                const SizedBox(height: 20),

                // --- PASSWORD FIELD ANIMATION ---
                _buildCustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword, // Dynamic obscureText
                  suffixIcon: IconButton(        // Added suffix toggle button
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                )
                .animate()
                .fade(duration: 600.ms, delay: 300.ms)
                .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 300.ms),
                
                const SizedBox(height: 32),

                // --- LOGIN BUTTON / SPINNER ANIMATION ---
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64B5F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // --- DIVIDER ANIMATION ---
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[400])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or sign in with',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[400])),
                        ],
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 500.ms)
                      .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 500.ms),
                      
                      const SizedBox(height: 24),

                      // --- GOOGLE BUTTON ANIMATION ---
                      _buildSocialButton(
                        imagePath: 'assets/images/google.png',
                        label: 'Google',
                        onPressed: _signInWithGoogle,
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 600.ms),
                      
                      const SizedBox(height: 16),

                      // --- FACEBOOK BUTTON ANIMATION ---
                      _buildSocialButton(
                        imagePath: 'assets/images/facebook.png',
                        label: 'Facebook',
                        onPressed: () {},
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 700.ms)
                      .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 700.ms),
                      
                      const SizedBox(height: 32),

                      // --- FOOTER TEXT ANIMATION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.grey[700], 
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFFFF6B2C), 
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 800.ms)
                      .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 800.ms),
                    ],
                  )
                  .animate()
                  .fade(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon, // Added parameter
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF0B3C6A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF64B5F6)), 
        suffixIcon: suffixIcon, // Apply parameter
        filled: true,
        fillColor: Colors.white.withOpacity(0.8), 
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2.5), 
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(imagePath, width: 24, height: 24),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0B3C6A),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFDF4),
        foregroundColor: const Color(0xFF0B3C6A),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.grey[300]!, width: 1), 
        ),
        elevation: 0,
      ),
    );
  }
}