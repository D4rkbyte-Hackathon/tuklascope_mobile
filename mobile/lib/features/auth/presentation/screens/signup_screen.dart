import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../onboarding/compass_questions_screen.dart';
import 'login_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/neon_text_field.dart';
import '../../providers/auth_controller.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/navigation/auth_transitions.dart';

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
  bool _isDropdownOpen = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty) return _showSnackBar('Please enter your name');
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) return _showSnackBar('Please enter an email and password');
    if (_passwordController.text.trim().length < 6) return _showSnackBar('Password must be at least 6 characters');
    if (_selectedEducationLevel == null) return _showSnackBar('Please select your educational level');

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

        if (!mounted) return;
        _showSnackBar('Account created successfully!', isError: false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()));
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      String errorMessage = e.message;
      if (errorMessage.toLowerCase().contains('user') || errorMessage.toLowerCase().contains('already') || errorMessage.toLowerCase().contains('email')) {
        _emailController.clear();
        errorMessage = 'This email is already registered. Please try logging in.';
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEducationLevelPicker() async {
    setState(() => _isDropdownOpen = true);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      isScrollControlled: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context); 
        final primaryNeon = theme.colorScheme.secondary;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 5, margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  ),
                  Text('Select Educational Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  
                  ..._educationLevels.map((level) {
                    final isSelected = _selectedEducationLevel == level;
                    return ListTile(
                      onTap: () {
                        setState(() => _selectedEducationLevel = level);
                        Navigator.pop(context); 
                      },
                      title: Text(
                        level,
                        style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? primaryNeon : theme.colorScheme.onSurface),
                      ).animate(target: isSelected ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms),
                      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primaryNeon).animate().scale(curve: Curves.easeOutBack, duration: 300.ms) : null,
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

    if (mounted) setState(() => _isDropdownOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNeon = theme.colorScheme.secondary;

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    shadows: [Shadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                NeonTextField(controller: _nameController, label: 'Name', icon: Icons.person_outline, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 150.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(controller: _cityController, label: 'City (Optional)', icon: Icons.location_city_outlined, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(controller: _countryController, label: 'Country (Optional)', icon: Icons.public_outlined, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 250.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                
                _buildNeonEducationSelector(theme, primaryNeon).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                
                const SizedBox(height: 16),
                NeonTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 350.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                
                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: primaryNeon,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),

                const SizedBox(height: 32),

                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: primaryNeon))
                else ...[
                  PrimaryAuthButton(
                    label: 'Sign Up',
                    onPressed: _signUp,
                    glowColor: primaryNeon,
                    gradientColors: [theme.colorScheme.tertiary, theme.colorScheme.secondary],
                    textColor: theme.colorScheme.onSecondary,
                  ).animate().fade(duration: 600.ms, delay: 450.ms),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, createAnimatedAuthRoute(const LoginScreen(), slideLeft: false)),
                        child: Text('Log In', style: TextStyle(color: theme.colorScheme.primary, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 550.ms),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonEducationSelector(ThemeData theme, Color primaryNeon) {
    final bool isPopulated = _selectedEducationLevel != null;
    final bool isFocused = _isDropdownOpen;

    return GestureDetector(
      onTap: _showEducationLevelPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18), 
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isFocused ? primaryNeon : Colors.transparent, width: isFocused ? 2.0 : 0.0),
          boxShadow: isFocused
              ? [BoxShadow(color: primaryNeon.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 4))]
              : [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(Icons.school_outlined, color: isFocused ? primaryNeon : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Text(
              _selectedEducationLevel ?? 'Educational Level',
              style: TextStyle(fontSize: 16, color: isPopulated ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: isFocused ? primaryNeon : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 28),
          ],
        ),
      ),
    );
  }
}