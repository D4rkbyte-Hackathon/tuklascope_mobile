import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../onboarding/compass_questions_screen.dart';
import '../../../onboarding/splash_screen.dart';
import 'login_screen.dart';
import '../../providers/auth_controller.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedEducationLevel;
  final List<String> _educationLevels = [
    'Elementary',
    'High School',
    'Senior High School',
    'Others',
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    // Validate email and password
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email and password')),
      );
      return;
    }

    // Validate password length
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (_selectedEducationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your educational level')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Delegate signup to the AuthController
      final authResponse = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      final user = authResponse.user;

      if (user != null) {
        // 2. The DB Trigger created the raw profile. Now we UPDATE it with the extra info!
        // We use .update().eq() instead of .upsert() to respect the strict Row Level Security policies.
        await Supabase.instance.client
            .from('profiles')
            .update({
              'full_name': _nameController.text.trim(),
              'city': _cityController.text.trim(),
              'country': _countryController.text.trim(),
              'education_level': _selectedEducationLevel,
            })
            .eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // 🚀 TECH LEAD FIX: We MUST route new users to the Compass Quiz!
          // If we send them to the AuthGate/SplashScreen, it will skip onboarding.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CompassQuestionsScreen(),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message;

        // Check if email already exists
        if (errorMessage.toLowerCase().contains('user') ||
            errorMessage.toLowerCase().contains('already') ||
            errorMessage.toLowerCase().contains('email')) {
          // Clear the email field for user convenience
          _emailController.clear();
          errorMessage =
              'This email is already registered. Please use a different email or try logging in.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("🚨 SIGNUP ERROR: $e"); // Fixed print warning
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
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
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B3C6A),
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 100.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 100.ms,
                    ),

                const SizedBox(height: 32),

                _buildCustomTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person_outline,
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 150.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 150.ms,
                    ),

                const SizedBox(height: 16),

                _buildCustomTextField(
                      controller: _cityController,
                      label: 'City (Optional)',
                      icon: Icons.location_city_outlined,
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 200.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 200.ms,
                    ),

                const SizedBox(height: 16),

                _buildCustomTextField(
                      controller: _countryController,
                      label: 'Country (Optional)',
                      icon: Icons.public_outlined,
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 250.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 250.ms,
                    ),

                const SizedBox(height: 16),

                _buildCustomDropdown(
                      label: 'Educational Level',
                      icon: Icons.school_outlined,
                      value: _selectedEducationLevel,
                      items: _educationLevels,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEducationLevel = newValue;
                        });
                      },
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 300.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 300.ms,
                    ),

                const SizedBox(height: 16),

                _buildCustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 350.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 350.ms,
                    ),

                const SizedBox(height: 16),

                _buildCustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    .fade(duration: 600.ms, delay: 400.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                      delay: 400.ms,
                    ),

                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                            onPressed: _signUp,
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .animate()
                          .fade(duration: 600.ms, delay: 450.ms)
                          .slideY(
                            begin: -0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                            delay: 450.ms,
                          ),

                      const SizedBox(height: 24),

                      Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
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
                          .fade(duration: 600.ms, delay: 550.ms)
                          .slideY(
                            begin: -0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                            delay: 550.ms,
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

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8), // Fixed deprecation
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 2.5),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Color(0xFF0B3C6A))),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64B5F6)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF64B5F6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8), // Fixed deprecation
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFFFF6B2C), width: 2.5),
        ),
      ),
    );
  }
}
