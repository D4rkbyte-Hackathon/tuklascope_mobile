// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../onboarding/splash_screen.dart';
import '../../../onboarding/compass_questions_screen.dart'; // 🚀 RE-ADDED: Need this to pass to splash screen
import '../../../profile/services/profile_service.dart'; // 🚀 ADDED: To use your working image upload logic
import 'login_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/email_verification_otp_modal.dart';
import '../widgets/neon_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/navigation/auth_transitions.dart';

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

  final SupabaseAuthService _authService = SupabaseAuthService();

  String? _selectedEducationLevel;
  final List<String> _educationLevels = ['Elementary', 'High School', 'Senior High School', 'Others'];

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDropdownOpen = false;

  // AVATAR SCROLLER STATE VARIABLES
  File? _customProfileImage;
  int _selectedAvatarIndex = 1; 
  final int _basePage = 5500; 
  late PageController _avatarPageController;

  final List<String> _avatarOptions = [
    'CUSTOM',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas1&backgroundColor=b6e3f4',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas2&backgroundColor=c0aede',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas3&backgroundColor=d1d4f9',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas4&backgroundColor=ffd5dc',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas5&backgroundColor=ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas6&backgroundColor=b6e3f4',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas7&backgroundColor=c0aede',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas8&backgroundColor=d1d4f9',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas9&backgroundColor=ffd5dc',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Tuklas10&backgroundColor=ffdfbf',
  ];

  @override
  void initState() {
    super.initState();
    _avatarPageController = PageController(viewportFraction: 0.35, initialPage: _basePage + 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _avatarPageController.dispose();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _customProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty) return _showSnackBar('Please enter your name');
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) return _showSnackBar('Please enter an email and password');
    if (_passwordController.text.trim().length < 6) return _showSnackBar('Password must be at least 6 characters');
    if (_selectedEducationLevel == null) return _showSnackBar('Please select your educational level');
    if (_selectedAvatarIndex == 0 && _customProfileImage == null) return _showSnackBar('Please select a custom profile image or pick an avatar');

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidEmailFormat(email)) {
      return _showSnackBar('Please enter a valid email format.');
    }

    setState(() => _isLoading = true);

    try {
      // 🚀 FIX: Actually utilizing the email existence check before doing anything else
      final emailExists = await _authService.checkIfEmailExists(email);
      if (emailExists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return _showSnackBar('This email is already registered. Please log in.');
      }

      await _authService.sendSignupVerificationOtp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final verified = await EmailVerificationOtpModal.show(
        context,
        email: email,
        onVerify: (code) => _authService.verifyEmailWithOtp(
          email: email,
          otpCode: code,
        ),
        onResend: () => _authService.resendSignupVerificationOtp(email: email),
      );

      if (verified == true && mounted) {
        await _completeSignupAfterVerification();
      }

    } on AuthException catch (e) {
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

  Future<void> _completeSignupAfterVerification() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        String? finalAvatarUrl;

        if (_selectedAvatarIndex == 0 && _customProfileImage != null) {
          finalAvatarUrl = await ref
              .read(profileServiceProvider)
              .uploadProfilePicture(_customProfileImage!.path);
        } else if (_selectedAvatarIndex > 0) {
          finalAvatarUrl = _avatarOptions[_selectedAvatarIndex];
        }

        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'city': _cityController.text.trim(),
          'country': _countryController.text.trim(),
          'education_level': _selectedEducationLevel,
          'profile_picture_url': finalAvatarUrl,
        }).eq('id', user.id);
      } catch (e) {
        debugPrint('Error updating profile: $e');
        if (mounted) {
          _showSnackBar('Profile update warning: $e', isError: true);
        }
      }
    }

    if (!mounted) return;
    _showSnackBar('Account created successfully!', isError: false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SplashScreen(nextScreen: CompassQuestionsScreen()),
      ),
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
                  Text('Select Educational Level', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
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
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? primaryNeon : theme.colorScheme.onSurface),
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
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    shadows: [Shadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),
                
                _buildAvatarScroller(theme).animate().fade(duration: 600.ms, delay: 150.ms).scaleXY(begin: 0.8, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
                
                Text(
                  'Choose your avatar or upload a picture.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ).animate().fade(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 32),

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

                NeonTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  neonColor: primaryNeon,
                  isRequired: true
                ).animate().fade(duration: 600.ms, delay: 350.ms).slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),

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
                      Text("Already have an account? ", style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, createAnimatedAuthRoute(const LoginScreen(), slideLeft: false)),
                        child: Text('Log In', style: GoogleFonts.montserrat(color: theme.colorScheme.primary, fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _buildAvatarScroller(ThemeData theme) {
    return SizedBox(
      height: 110,
      child: PageView.builder(
        controller: _avatarPageController,
        onPageChanged: (int page) {
          setState(() {
            _selectedAvatarIndex = page % 11;
          });
        },
        itemBuilder: (context, index) {
          final int realIndex = index % 11;
          return AnimatedBuilder(
            animation: _avatarPageController,
            builder: (context, child) {
              double value = 1.0;
              if (_avatarPageController.position.haveDimensions) {
                value = _avatarPageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
              } else {
                value = (index == _basePage + 1) ? 1.0 : 0.7; 
              }
              
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 100, 
                  width: Curves.easeOut.transform(value) * 100,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                _avatarPageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                if (realIndex == 0) {
                  _pickImage();
                }
              },
              child: _buildAvatarItem(realIndex, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarItem(int index, ThemeData theme) {
    final isSelected = _selectedAvatarIndex == index;
    
    if (index == 0) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 4 : 1,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
              : [],
          image: _customProfileImage != null 
              ? DecorationImage(image: FileImage(_customProfileImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _customProfileImage == null 
            ? Icon(Icons.add_a_photo_rounded, color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 32)
            : null,
      );
    } 
    else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
            width: isSelected ? 4 : 0,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: ClipOval(
          child: Image.network(
            _avatarOptions[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
               if (progress == null) return child;
               return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary.withValues(alpha: 0.5)));
            },
            errorBuilder: (context, error, stack) => Icon(Icons.person, color: theme.colorScheme.primary),
          ),
        ),
      );
    }
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

bool isValidEmailFormat(String email) {
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
  );
  return emailRegex.hasMatch(email);
}