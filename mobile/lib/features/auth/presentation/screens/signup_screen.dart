import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../onboarding/compass_questions_screen.dart';
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
  final List<String> _educationLevels = ['Elementary', 'High School', 'Senior High School', 'Others'];

  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // 🚀 Added this state variable to track when the modal is actively open
  bool _isDropdownOpen = false; 

  final Color primaryNeon = const Color(0xFFFF6B2C); // Using the orange theme for Signup to contrast Login

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an email and password')));
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    if (_selectedEducationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your educational level')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResponse = await ref.read(authControllerProvider.notifier).signUpWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      final user = authResponse.user;

      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'city': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'education_level': _selectedEducationLevel,
        }).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully!'), backgroundColor: Colors.green));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()));
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        if (errorMessage.toLowerCase().contains('user') || errorMessage.toLowerCase().contains('already') || errorMessage.toLowerCase().contains('email')) {
          _emailController.clear();
          errorMessage = 'This email is already registered. Please try logging in.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Route _createAnimatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); 
        const end = Offset.zero;
        const curve = Curves.easeOutExpo;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  // --- 🚀 UPDATED: Now tracks open/close state via await ---
  void _showEducationLevelPicker() async {
    // 1. Turn on the glow
    setState(() => _isDropdownOpen = true);

    // 2. Wait for the modal to close
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF4), 
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    'Select Educational Level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3C6A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._educationLevels.map((level) {
                    final isSelected = _selectedEducationLevel == level;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _selectedEducationLevel = level;
                        });
                        Navigator.pop(context); 
                      },
                      title: Text(
                        level,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? primaryNeon : const Color(0xFF0B3C6A),
                        ),
                      ).animate(target: isSelected ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms),
                      
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: primaryNeon)
                              .animate().scale(curve: Curves.easeOutBack, duration: 300.ms)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );

    // 3. Turn off the glow when the modal is completely closed
    if (mounted) {
      setState(() => _isDropdownOpen = false);
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
                    shadows: [Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                NeonTextField(controller: _nameController, label: 'Name', icon: Icons.person_outline, neonColor: primaryNeon)
                    .animate().fade(duration: 600.ms, delay: 150.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

                NeonTextField(controller: _cityController, label: 'City (Optional)', icon: Icons.location_city_outlined, neonColor: primaryNeon)
                    .animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

                NeonTextField(controller: _countryController, label: 'Country (Optional)', icon: Icons.public_outlined, neonColor: primaryNeon)
                    .animate().fade(duration: 600.ms, delay: 250.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

                _buildNeonEducationSelector()
                    .animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

                NeonTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, neonColor: primaryNeon)
                    .animate().fade(duration: 600.ms, delay: 350.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: primaryNeon,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),

                const SizedBox(height: 32),

                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: primaryNeon))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: primaryNeon.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5)),
                          ],
                          gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6B2C)]),
                        ),
                        child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ).animate().fade(duration: 600.ms, delay: 450.ms),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, _createAnimatedRoute(const LoginScreen())),
                            child: const Text('Log In', style: TextStyle(color: Color(0xFF64B5F6), fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ).animate().fade(duration: 600.ms, delay: 550.ms),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🚀 UPDATED: Logic separated for "populated" vs "focused" ---
  Widget _buildNeonEducationSelector() {
    bool isPopulated = _selectedEducationLevel != null;
    bool isFocused = _isDropdownOpen; // Now exclusively tied to the modal being open

    return GestureDetector(
      onTap: _showEducationLevelPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18), 
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          // Glow/Border is only active when isFocused is TRUE
          border: Border.all(
            color: isFocused ? primaryNeon : Colors.transparent,
            width: isFocused ? 2.0 : 0.0,
          ),
          boxShadow: isFocused
              ? [BoxShadow(color: primaryNeon.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Icon stays orange when focused, otherwise goes grey
            Icon(Icons.school_outlined, color: isFocused ? primaryNeon : Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              _selectedEducationLevel ?? 'Educational Level',
              style: TextStyle(
                fontSize: 16,
                // Text stays Dark Blue if they made a selection, Grey if empty
                color: isPopulated ? const Color(0xFF0B3C6A) : Colors.grey[600],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: isFocused ? primaryNeon : Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }
}