import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS

import '../../../onboarding/compass_questions_screen.dart';
import 'login_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/neon_text_field.dart';
import '../../providers/auth_controller.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/navigation/auth_transitions.dart';

// Import your auth service to access the OTP functions
import '../../services/supabase_auth_service.dart';

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

  // Instantiate the Auth Service here
  final SupabaseAuthService _authService = SupabaseAuthService();

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

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidEmailFormat(email)) {
      return _showSnackBar('Please enter a valid email format.');
    }

    setState(() => _isLoading = true);

    try {
      // 🚀 Trigger the OTP Send
      await _authService.sendSignupVerificationOtp(
        email: email,
        password: password,
      );

      // 🚀 If the code reaches this line without throwing an error, it was a success!
      if (!mounted) return;
      _showOtpVerificationDialog(email);

    } on AuthException catch (e) {
      // 🚀 Catches Supabase errors (like rate limits) AND our custom "Email exists" error
      if (!mounted) return;
      _passwordController.clear();
      _showSnackBar(e.message); 
    } catch (e) {
      if (!mounted) return;
      _passwordController.clear();
      _showSnackBar('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🚀 STEP 4: The OTP Verification Step
  void _showOtpVerificationDialog(String email) {
    final TextEditingController otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder( // Allows the dialog to show a loading spinner inside itself
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Verify Your Email', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)), // 🚀 SWAPPED TO MONTSERRAT
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the 6-digit code sent to $email to prove you are human!', style: GoogleFonts.inter()), // 🚀 SWAPPED TO INTER
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '6-digit OTP',
                      hintText: '000000',
                    ),
                    enabled: !isVerifying,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.inter()), // 🚀 SWAPPED TO INTER
                ),
                ElevatedButton(
                  onPressed: isVerifying ? null : () async {
                    final code = otpController.text.trim();
                    if (code.isEmpty) return;

                    setDialogState(() => isVerifying = true);

                    // Validate the code
                    final verified = await _authService.verifyEmailWithOtp(
                      email: email, 
                      otpCode: code,
                    );

                    if (verified) {
                      // SUCCESS! User is now verified and logged in.
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        try {
                          // 🚀 FIXED: Added 'id' inside the map, and removed .eq() at the end
                          await Supabase.instance.client.from('profiles').upsert({
                            'id': user.id, // 👈 CRITICAL: Must be inside the payload
                            'full_name': _nameController.text.trim(),
                            'city': _cityController.text.trim(),
                            'country': _countryController.text.trim(),
                            'education_level': _selectedEducationLevel,
                          });
                        } catch (e) {
                          debugPrint('Error updating profile: $e');
                        }
                      }

                      if (!mounted) return;
                      Navigator.pop(context); // Close dialog
                      _showSnackBar('Account created successfully!', isError: false);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CompassQuestionsScreen()));
                    }
                  },
                  child: isVerifying 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : Text('Verify', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), // 🚀 SWAPPED TO INTER
                ),
              ],
            );
          }
        );
      },
    );
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
                  Text('Select Educational Level', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)), // 🚀 SWAPPED TO MONTSERRAT
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
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? primaryNeon : theme.colorScheme.onSurface), // 🚀 SWAPPED TO INTER
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
                  style: GoogleFonts.montserrat( // 🚀 SWAPPED TO MONTSERRAT
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    shadows: [Shadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                // 🚀 ADDED: isRequired: true
                NeonTextField(
                  controller: _nameController, 
                  label: 'Name', 
                  icon: Icons.person_outline, 
                  neonColor: primaryNeon, 
                  isRequired: true
                ).animate().fade(duration: 600.ms, delay: 150.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(controller: _cityController, label: 'City (Optional)', icon: Icons.location_city_outlined, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(controller: _countryController, label: 'Country (Optional)', icon: Icons.public_outlined, neonColor: primaryNeon).animate().fade(duration: 600.ms, delay: 250.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                
                _buildNeonEducationSelector(theme, primaryNeon).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                
                const SizedBox(height: 16),
                
                // 🚀 ADDED: isRequired: true
                NeonTextField(
                  controller: _emailController, 
                  label: 'Email', 
                  icon: Icons.email_outlined, 
                  keyboardType: TextInputType.emailAddress, 
                  neonColor: primaryNeon, 
                  isRequired: true
                ).animate().fade(duration: 600.ms, delay: 350.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                
                // 🚀 ADDED: isRequired: true
                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: primaryNeon,
                  isRequired: true,
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
                      Text("Already have an account? ", style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15)), // 🚀 SWAPPED TO INTER
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, createAnimatedAuthRoute(const LoginScreen(), slideLeft: false)),
                        child: Text('Log In', style: GoogleFonts.montserrat(color: theme.colorScheme.primary, fontSize: 15, fontWeight: FontWeight.bold)), // 🚀 SWAPPED TO MONTSERRAT
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
            // 🚀 CHANGED: Swapped standard Text for RichText to support the required asterisk
            RichText(
              text: TextSpan(
                text: _selectedEducationLevel ?? 'Educational Level',
                style: GoogleFonts.inter(
                  fontSize: 16, 
                  color: isPopulated ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6)
                ), 
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: isFocused ? primaryNeon : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 28),
          ],
        ),
      ),
    );
  }
}

// 🚀 HELPER FUNCTION: Placed securely at the bottom
bool isValidEmailFormat(String email) {
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
  );
  return emailRegex.hasMatch(email);
}