import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../onboarding/compass_questions_screen.dart';

// Import our Riverpod provider so we can access Supabase
import '../../providers/auth_provider.dart';

import '../../../../core/widgets/gradient_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers to read what the user types
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Loading state to show a spinner while talking to Supabase
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Read the auth service and attempt to sign in
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

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Read the auth service and attempt to register a new user
      await ref
          .read(authServiceProvider)
          .signUpWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success! You are now registered.')),
        );
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      // We removed the AppBar to give it a modern, full-screen clean look
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Login" Text at the top
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B3C6A), // Tuklascope Dark Blue
                  ),
                ),
                const SizedBox(height: 48),

                // Email Textbar
                _buildCustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Textbar
                _buildCustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Custom Login Button
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64B5F6), // Your specified blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // "Or sign in with" Divider
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
                      ),
                      const SizedBox(height: 24),

                      // Google Button
                      _buildSocialButton(
                        icon: Icons.g_mobiledata, // Placeholder Google icon
                        label: 'Google',
                        onPressed: () {
                          // TODO: Implement Google Sign In
                        },
                      ),
                      const SizedBox(height: 16),

                      // Facebook Button
                      _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onPressed: () {
                          // TODO: Implement Facebook Sign In
                        },
                      ),
                      const SizedBox(height: 32),

                      // Create Account Button
                      OutlinedButton(
                        onPressed: _signUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF9800), // Your specified Orange
                          side: const BorderSide(color: Color(0xFFFF9800), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER METHODS FOR CLEAN UI ---

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF0B3C6A)), // Dark text for typing
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF64B5F6)), // The light blue icon
        filled: true,
        fillColor: Colors.white.withOpacity(0.8), // Slightly transparent white fill
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5), // Light blue border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2.5), // Thicker when tapped
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28, color: const Color(0xFF0B3C6A)),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0B3C6A),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFDF4), // Your specified cream color
        foregroundColor: const Color(0xFF0B3C6A),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // Subtle border to make it pop against the background
          side: BorderSide(color: Colors.grey[300]!, width: 1), 
        ),
        elevation: 0,
      ),
    );
  }
}