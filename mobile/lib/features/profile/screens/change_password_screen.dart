import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/gradient_scaffold.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? theme.colorScheme.error : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      
      if (mounted) {
        _showSnackBar('Security updated: Password changed successfully!');
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Buffed Neutral Glass Card
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // Neutralized borders instead of heavy primary colors
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildCustomHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _buildGlassCard(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface, 
                size: 20,
              ),
            ),
          ),
          Text(
            'CHANGE PASSWORD',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 44), 
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        _buildGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.primary, // Accent color for interaction
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                onPressed: toggleObscure,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Choreography: Header drops in first
            _buildCustomHeader()
                .animate()
                .fade(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Shiny: Quantum Shield Animation
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 100.ms)
                      .scaleXY(begin: 0.5, curve: Curves.easeOutBack)
                      // The infinite shiny glow
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 2.seconds, color: theme.colorScheme.secondary.withValues(alpha: 0.5))
                      .scaleXY(end: 1.05, curve: Curves.easeInOutSine),
                      
                      const SizedBox(height: 32),
                      
                      Center(
                        child: Text(
                          'Update Authentication',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 8),
                      
                      Center(
                        child: Text(
                          'Ensure your new password is at least 6 characters long and hard to guess.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: 48),

                      // Choreography: Inputs slide in sequentially
                      _buildPasswordField(
                        label: 'NEW PASSWORD',
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password cannot be empty';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ).animate().fade(delay: 400.ms).slideX(begin: 0.05),

                      const SizedBox(height: 24),

                      _buildPasswordField(
                        label: 'CONFIRM PASSWORD',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ).animate().fade(delay: 500.ms).slideX(begin: 0.05),

                      const SizedBox(height: 48),

                      // Shiny: Action Button with Shimmer Sweep
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          onPressed: _isLoading ? null : _updatePassword,
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'OVERRIDE PROTOCOL',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      )
                      .animate().fade(delay: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutBack)
                      // Infinite sweeping highlight on the button
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 3.seconds, delay: 1.seconds, color: Colors.white.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}