import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../onboarding/compass_questions_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/neon_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

class SocialLoginProfileScreen extends ConsumerStatefulWidget {
  final String? initialName;
  final String userEmail;

  const SocialLoginProfileScreen({
    super.key,
    this.initialName,
    required this.userEmail,
  });

  @override
  ConsumerState<SocialLoginProfileScreen> createState() =>
      _SocialLoginProfileScreenState();
}

class _SocialLoginProfileScreenState
    extends ConsumerState<SocialLoginProfileScreen> {
  late final TextEditingController _nameController;
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedEducationLevel;
  final List<String> _educationLevels = [
    'Elementary',
    'High School',
    'Senior High School',
    'Others'
  ];

  bool _isLoading = false;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from social login account info
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  Future<void> _completeProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      return _showSnackBar('Please enter your name');
    }
    if (_selectedEducationLevel == null) {
      return _showSnackBar('Please select your educational level');
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Update user profile in database
        await Supabase.instance.client
            .from('profiles')
            .update({
              'full_name': _nameController.text.trim(),
              'city': _cityController.text.trim(),
              'country': _countryController.text.trim(),
              'education_level': _selectedEducationLevel,
            })
            .eq('id', user.id);

        if (!mounted) return;
        _showSnackBar('Profile completed successfully!', isError: false);

        // Navigate to the next screen (CompassQuestionsScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompassQuestionsScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        _showSnackBar('User not found. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error updating profile: $e');
      _showSnackBar('Failed to complete profile: ${e.toString()}');
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
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'Select Educational Level',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
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
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? primaryNeon
                              : theme.colorScheme.onSurface,
                        ),
                      ).animate(target: isSelected ? 1 : 0)
                          .scaleXY(end: 1.05, duration: 200.ms),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: primaryNeon)
                              .animate()
                              .scale(
                                curve: Curves.easeOutBack,
                                duration: 300.ms,
                              )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ).animate().slideY(
              begin: 0.2,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );

    if (mounted) setState(() => _isDropdownOpen = false);
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
          border: Border.all(
            color: isFocused ? primaryNeon : Colors.transparent,
            width: isFocused ? 2.0 : 0.0,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: primaryNeon.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            Icon(Icons.school_outlined,
                color: isFocused
                    ? primaryNeon
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                text: _selectedEducationLevel ?? 'Educational Level',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isPopulated
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            Icon(Icons.arrow_drop_down_rounded,
                color: isFocused
                    ? primaryNeon
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 28),
          ],
        ),
      ),
    );
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
                  'Complete Your Profile',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    shadows: [
                      Shadow(
                        color: theme.shadowColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                ).animate()
                    .fade(duration: 600.ms, delay: 100.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 12),
                Text(
                  'Logged in as: ${widget.userEmail}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate()
                    .fade(duration: 600.ms, delay: 120.ms),
                const SizedBox(height: 32),
                NeonTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  neonColor: primaryNeon,
                  isRequired: true,
                )
                    .animate()
                    .fade(duration: 600.ms, delay: 150.ms)
                    .slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(
                  controller: _cityController,
                  label: 'City (Optional)',
                  icon: Icons.location_city_outlined,
                  neonColor: primaryNeon,
                )
                    .animate()
                    .fade(duration: 600.ms, delay: 200.ms)
                    .slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                NeonTextField(
                  controller: _countryController,
                  label: 'Country (Optional)',
                  icon: Icons.public_outlined,
                  neonColor: primaryNeon,
                )
                    .animate()
                    .fade(duration: 600.ms, delay: 250.ms)
                    .slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 16),
                _buildNeonEducationSelector(theme, primaryNeon)
                    .animate()
                    .fade(duration: 600.ms, delay: 300.ms)
                    .slideX(begin: 0.1, end: 0, duration: 600.ms),
                const SizedBox(height: 32),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: primaryNeon),
                  )
                else
                  PrimaryAuthButton(
                    label: 'Complete Profile',
                    onPressed: _completeProfile,
                    glowColor: primaryNeon,
                    gradientColors: [
                      theme.colorScheme.tertiary,
                      theme.colorScheme.secondary
                    ],
                    textColor: theme.colorScheme.onSecondary,
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}